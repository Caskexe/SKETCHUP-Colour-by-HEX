#-------------------------------------------------------------------------------
#
# CASKexe (Github CASKexe)
# Colour by HEX
# Description: Simple tool to colour object(s) by HEX code
# Version: 1.0
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'extensions.rb'
require 'json'

module HexColourTool
	PLUGIN_NAME = "Colour by HEX"
	PLUGIN_ID = "colour_by_hex"

	def self.create_material_from_hex(hex_code)
		hex_code = hex_code.strip
		return nil unless hex_code.match(/^#?([A-Fa-f0-9]{6})$/)

		hex_code = "##{hex_code}" unless hex_code.start_with?("#")
		r = hex_code[1..2].hex
		g = hex_code[3..4].hex
		b = hex_code[5..6].hex

		model = Sketchup.active_model
		materials = model.materials
		mat_name = "HEX_#{hex_code[1..-1].upcase}"

		material = materials[mat_name]
		unless material
			material = materials.add(mat_name)
			material.color = Sketchup::Color.new(r, g, b)
		end

		material
	end

	def self.apply_material_to_selection(material)
		model = Sketchup.active_model
		entities = model.selection

		model.start_operation("Apply HEX Colour", true)
		entities.each do |entity|
			if entity.respond_to?(:material=)
				entity.material = material
			end
		end
		model.commit_operation
	end

	def self.show_dialog
		html = <<-HTML
			<!DOCTYPE html>
			<html>
			<head>
				<style>
					body { font-family: sans-serif; padding: 10px; }
					input { font-size: 16px; margin-bottom: 10px; }
					button { font-size: 16px; }
				</style>
			</head>
			<body>
				<label>Enter HEX Colour Code:</label><br>
				<input type="text" id="hexCode" value="#ff0000" /><br>
				<button onclick="applyColour()">Apply</button>
				<script>
					function applyColour() {
						const hex = document.getElementById('hexCode').value;
						window.sketchup.applyHex(hex);
					}
				</script>
			</body>
			</html>
		HTML

		dialog = UI::HtmlDialog.new({
			:dialog_title => "Colour by HEX",
			:preferences_key => "colour_by_hex",
			:scrollable => true,
			:resizable => false,
			:width => 300,
			:height => 180,
			:style => UI::HtmlDialog::STYLE_DIALOG
		})

		dialog.set_html(html)
		dialog.add_action_callback("applyHex") do |_context, hex_code|
			material = create_material_from_hex(hex_code)
			if material
				apply_material_to_selection(material)
			else
				UI.messagebox("Invalid HEX code. Please use format #RRGGBB.")
			end
		end

		dialog.show
	end

	unless file_loaded?(__FILE__)
		UI.menu("Plugins").add_item(PLUGIN_NAME) {
			self.show_dialog
		}
		file_loaded(__FILE__)
	end
end