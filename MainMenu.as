﻿package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.text.*;
	
	public class MainMenu extends World
	{
		[Embed(source="title.png")]
		public static var titleGfx: Class;
		
		public var buttons: Array = [];
		
		public var bgColour: Number = 0;
		
		public var alan: MyTextField;
		public var macleod: MyTextField;
		
		public function MainMenu ()
		{
			AudioControl.init();
			
			do {
				var r: Number = Math.random();
				var g: Number = Math.random();
				var b: Number = Math.random();
			}
			while (r + g + b < 1);
			
			var title: Image = new Image(titleGfx);
			
			title.color = (uint(r*255) << 16) | (uint(g*255) << 8) | uint(b*255);
			
			/*Text.align = "center";
			Text.font = "modenine";
			Text.size = 16;*/
			
			var ss:StyleSheet = new StyleSheet();
            ss.parseCSS("a:hover { text-decoration: underline; } a { text-decoration: none; }");
			
			alan = new MyTextField(320, 227, "");
			alan.htmlText = 'Created by <a href="http://www.draknek.org/" target="_blank">Alan Hazelden</a>';
			alan.mouseEnabled = true;
			alan.styleSheet = ss;
			
			macleod = new MyTextField(320, 227, "");
			macleod.htmlText = 'Music by <a href="http://www.incompetech.com/" target="_blank">Kevin MacLeod</a>';
			macleod.mouseEnabled = true;
			macleod.styleSheet = ss;
			macleod.visible = false;
			
			alan.x = 320 - alan.width*0.5;
			macleod.x = 320 - macleod.width*0.5;
			
			add(new Entity(0, 0, title));
			
			var button: Button;
			
			button = new Button("Play", 255)
			buttons.push(button);
			button.addEventListener(MouseEvent.CLICK, function (): void {
				FP.world = new Level();
			});
			
			button = new Button("Highscores", 310)
			buttons.push(button);
			button.addEventListener(MouseEvent.CLICK, function (): void {
				Mochi.showScores();
			});
			
			button = new Button(AudioControl.mute ? "Audio: off" : "Audio: on", 365)
			buttons.push(button);
			var audioButton: Button = button;
			button.addEventListener(MouseEvent.CLICK, function (): void {
				AudioControl.toggleSound();
				
				if (AudioControl.mute) {
					audioButton.textField.text = "Audio: off";
				} else {
					audioButton.textField.text = "Audio: on";
				}
			});
			
			button = new Button("More games", 420)
			buttons.push(button);
			button.addEventListener(MouseEvent.CLICK, function (): void {
				// nothing
			});
		}
		
		public override function begin (): void
		{
			FP.camera.x = 0;
			for each (var b: Button in buttons) {
				FP.engine.addChild(b);
			}
			
			FP.engine.addChild(alan);
			FP.engine.addChild(macleod);
		}
		
		public override function end (): void
		{
			for each (var b: Button in buttons) {
				FP.engine.removeChild(b);
			}
			
			FP.engine.removeChild(alan);
			FP.engine.removeChild(macleod);
		}
		
		public override function update (): void
		{
			bgColour += 0.01;
			
			if (bgColour % 4 < 2) {
				alan.visible = true;
				macleod.visible = false;
			} else {
				alan.visible = false;
				macleod.visible = true;
			}
		}
		
		public override function render (): void
		{
			var t: Number = (bgColour + Input.mouseX / 640.0 / 2.0) % 6;
			
			var r: Number, g: Number, b: Number;
			
			if (t < 2) {
				r = 1;
				g = (t < 1) ? 0 : t - 1;
				b = (t < 1) ? 1 - t : 0;
			} else if (t < 4) {
				t -= 2;
				g = 1;
				b = (t < 1) ? 0 : t - 1;
				r = (t < 1) ? 1 - t : 0;
			} else {
				t -= 4;
				b = 1;
				r = (t < 1) ? 0 : t - 1;
				g = (t < 1) ? 1 - t : 0;
			}
			
			FP.buffer.fillRect(FP.bounds, 0xFF000000 | (uint(r * 0x50)<<16) | (uint(g * 0x50)<<8) | (uint(b * 0x50)));
			
			super.render();
		}
	}
}


