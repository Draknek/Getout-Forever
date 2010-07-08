﻿package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
	import flash.ui.Mouse;
	
	public class Level extends World
	{
		[Embed(source="MODENINE.TTF", fontName='modenine', mimeType='application/x-font')]
		public static var modeNineFont : Class;
		
		[Embed(source="block.png")]
		public static var blockGfx: Class;
		
		[Embed(source="paddle.png")]
		public static var paddleGfx: Class;
		
		public var block: Image = new Image(blockGfx);
		
		public var paddleImage: Image = new Image(paddleGfx);
		
		public var missing: Object = {};
		
		public var rect: Rectangle = new Rectangle();
		
		public var ball: Point = new Point(400, 300);
		public var oldBall: Point = new Point(400, 300);
		public var velocity: Point = new Point(3.5, 3);
		public var paddle: Number = 320 - 64;
		
		public var freeCamera: Boolean = false;
		
		public var focused: Boolean = false;
		public var ballActive: Boolean = false;
		public var canStart: Boolean = true;
		public var gameover: Boolean = false;
		
		public var lives: int = 3;
		
		public var particles: Vector.<MyParticle> = new Vector.<MyParticle>();
		//public var particles: Array = new Array();
		
		public var recycleParticle: MyParticle = null;
		
		public var alphaBitmap: BitmapData = null;
		public var lastBuffer: BitmapData = null;
		
		public var colourOffset: uint;
		
		public var bgColour: Number = 0;
		
		public var updateCount: int = 0;
		
		public var score: NumberString;
		public var scoreText: Text;
		
		public var submitButton: Button;
		public var menuButton: Button;
		
		public function Level()
		{
			focusGain();
			
			Text.font = "modenine";
			Text.size = 32;
			Text.align = "center";
			
			scoreText = new Text("0", 320 - 50, 160, 100);
			scoreText.scrollX = 0;
			
			score = new NumberString();
			
			score.bind(scoreText, "text");
			
			colourOffset = Math.random() * int.MAX_VALUE;
			
			missing["-1x29"] = true;
			missing["20x29"] = true;
			
			/*for (var j: int = 8; j < 480/16; j++) {
				missing["-1x" + j] = true;
				missing["20x" + j] = true;
			}*/
			
			alphaBitmap = new BitmapData(640, 480, true, 0xA0000000);
			
			AudioControl.playMusic();
			
			Mochi.startPlay();
			
			FP.engine.addChild(new Button("Hello", 200));
		}
		
		public function getColour (ix: int, iy: int): uint
		{
			var colour: uint = Math.floor(ix / 20) * 98317 + Math.floor(iy / 2) * 393241 + 12289 + colourOffset;
			
			do {
				colour = uint(colour * 374321);
				var r: uint = (colour >> 16) & 0xFF;
				var g: uint = (colour >> 8) & 0xFF;
				var b: uint = (colour) & 0xFF;
			}
			while (r + g + b < 255);
			
			
			return (0xFF000000 | colour);
		}
		
		public override function begin (): void
		{
			FP.stage.addEventListener(Event.ACTIVATE, focusGain);
			FP.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseClick);
			FP.stage.addEventListener(Event.DEACTIVATE, focusLost);
		}
		
		public override function end (): void
		{
			FP.stage.removeEventListener(Event.ACTIVATE, focusGain);
			FP.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseClick);
			FP.stage.removeEventListener(Event.DEACTIVATE, focusLost);
			
			if (submitButton) FP.engine.removeChild(submitButton);
			if (menuButton) FP.engine.removeChild(menuButton);
		}
		
		private function mouseClick(e:Event):void
		{
			if (gameover) { return; }
			
			if (canStart) {
				canStart = false;
				ballActive = true;
				
				velocity.y = -3.0 - 0.5 * (Math.abs(velocity.y) - 3.0);
				velocity.x = 3.5 * Math.abs(velocity.y) / 3.0
				
				if (ball.x - FP.camera.x < 320 - 3) {
					velocity.x *= -1;
				}
				
				if (freeCamera) {
					velocity.x += (Input.mouseX - 320) * 0.025;
				}
			}
			
			focusGain();
		}
		
		private function focusGain(e:Event = null):void
		{
			focused = true;
			Mouse.hide();
		}
		
		private function focusLost(e:Event = null):void
		{
			focused = false;
			Mouse.show();
		}
		
		public override function update (): void
		{
			updateCount++;
			
			AudioControl.rainVolume *= 0.99;
			
			bgColour += 0.01;
			
			if (gameover) { return; }
			
			if (! focused && ballActive) { return; }
			
			paddle = Input.mouseX - 64 + FP.camera.x;
			
			if (! ballActive) {
				if (! canStart) {
					var dx: Number = paddle + 64 - 3 - ball.x;
					var dy: Number = 480 - 14 - ball.y;
					var dz: Number = Math.sqrt(dx*dx + dy*dy);
					
					const speed: Number = velocity.x;
					
					velocity.x += 1;
					
					if (dz > speed) {
						ball.x += speed * dx / dz;
						ball.y += speed * dy / dz;
						
						return;
					} else {
						canStart = true;
					}
				}
				
				ball.x = paddle + 64 - 3;
				ball.y = 480 - 14;
				
				return;
			}
			
			if (freeCamera) {
				FP.camera.x += (Input.mouseX - 320) * 0.05;
			}
			
			ball.x += velocity.x;
			ball.y += velocity.y;
			
			// collide against blocks
			
			var tmp: int;
			
			var ix1: int = Math.floor(ball.x / 32);
			var ix2: int = Math.floor((ball.x + 6) / 32);
			
			if (velocity.x < 0) {
				tmp = ix1;
				ix1 = ix2;
				ix2 = tmp;
			}
			
			var iy1: int = Math.floor(ball.y / 16);
			var iy2: int = Math.floor((ball.y + 6) / 16);
			
			if (velocity.y < 0) {
				tmp = iy1;
				iy1 = iy2;
				iy2 = tmp;
			}
			
			// collide against floor/ceiling
			
			var bounced: Boolean = false;
			
			if (ball.y < 0) { velocity.y *= -1; ball.y = 0; bounced = true; }
			else if (ball.y > 480-6-8) {
				var paddleDiff: Number = ball.x - paddle;
				
				if (paddleDiff > -6 && paddleDiff < 128) {
					velocity.x = ((paddleDiff + 6) - 67) * 0.05 * Math.abs(velocity.y) / 3.0;
					
					if (freeCamera) {
						velocity.x += (Input.mouseX - 320) * 0.025;
					}
					
					velocity.y *= -1;
					velocity.y -= 0.05;
					ball.y = 480-6-8;
					
					bounced = true;
				} else if (ball.y > 480) {
					ballActive = false;
					
					AudioControl.playDeath();
					
					var p: MyParticle;
					
					for (var h1: int = 0; h1 < 6; h1++) {
						for (var h2: int = 0; h2 < 6; h2++) {
							if (recycleParticle) {
								p = recycleParticle;
								recycleParticle = p.recycleNext;
								p.recycleNext = null;
							} else {
								p = new MyParticle;
							}
							
							p.x = p.oldx = ball.x + h1;
							p.y = p.oldy = ball.y + h2;
							p.dx = /*-velocity.x +*/ ((h1-2.5) + Math.random() - 0.5) * 0.5 * (h2 + 2) / 6.0;
							p.dy = -velocity.y + h2 - 2 + Math.random() - 0.5;
							
							/*p.dx = p.dx * (Math.random() + 1) * 0.1;
							p.dy = p.dy * (Math.random() + 1) * 0.1;*/
							
							p.colour = 0xFFFFFF;
							
							particles.push(p);
						}
					}
					
					if (lives > 0) {
						ball.x = FP.camera.x + 20 * lives;
						ball.y = 16*8 + 20;
						oldBall.x = FP.camera.x + 20 * lives;
						oldBall.y = 16*8 + 20;
						velocity.x = 1;
						
						lives--;
					} else {
						gameover = true;
						
						Mochi.endPlay();
						
						Mouse.show();
					}
				}
			}
			
			var lookup: String;
			var hit: Boolean = false;
			
			// check up/down
			
			var ix: int = ix1;
			var iy: int = iy2;
			
			if (((iy < 8 && iy > -1) || ix == -1 || ix == 20) && ! missing[lookup = ix + "x" + iy]) {
				missing[lookup] = true;
				
				var points: int = 10 + int((7 - iy) / 2) * 20;
				
				if (iy >= 8) { points = 10; }
				
				score.value += points;
				
				addParticles(ix, iy);
				
				velocity.y *= -1;
				
				hit = true;
			}
			
			// check left/right
			
			ix = ix2;
			iy = iy1;
			
			if (((iy < 8 && iy > -1) || ix == -1 || ix == 20) && ! missing[lookup = ix + "x" + iy]) {
				missing[lookup] = true;
				
				points = 10 + int((7 - iy) / 2) * 20;
				
				if (iy >= 8) { points = 10; }
				
				score.value += points;
				
				addParticles(ix, iy);
				
				velocity.x *= -1;
				
				hit = true;
			}
			
			// check corner
			
			ix = ix2;
			iy = iy2;
			
			if (! hit && ((iy < 8 && iy > -1) || ix == -1 || ix == 20) && ! missing[lookup = ix + "x" + iy]) {
				missing[lookup] = true;
				
				points = 10 + int((7 - iy) / 2) * 20;
				
				if (iy >= 8) { points = 10; }
				
				score.value += points;
				
				addParticles(ix, iy);
				
				velocity.x *= -1;
				velocity.y *= -1;
				
				hit = true;
			}
			
			if (hit && Kongregate.api) {
				Kongregate.api.stats.submit("Score", score.value);
			}
			
			if (hit) {
				AudioControl.playBounceBlock();
			}
			
			if (bounced) {
				AudioControl.playBouncePaddle();
			}
			
			if (! freeCamera) {
				if (ball.x < -32 || ball.x > 640+32-6) {
					freeCamera = true;
					AudioControl.switchMusic();
				}
			}
			
			/*if (ball.x - FP.camera.x < 0) { ball.x = FP.camera.x; velocity.x = Math.abs(velocity.x); }
			else if (ball.x - FP.camera.x > 640-6) { ball.x = FP.camera.x + 640-6; velocity.x = -Math.abs(velocity.x); }*/
		}
		
		private function updateParticlesFilter (p: MyParticle, index: int, arr: Vector.<MyParticle>): Boolean
		{
			p.oldx = p.x;
			p.oldy = p.y;
			
			p.x += p.dx;
			p.y += p.dy;
			
			//p.dx *= 0.99;
			p.dy += 0.2;
			
			if (p.y > 480 - 8 && p.x > paddle && p.x < paddle + 128) {
				p.dy = -Math.abs(p.dy) * 0.5;
				p.oldy = 480-8;
				p.y = p.oldy + p.dy;
				
				if (p.dy > -1) {
					p.recycleNext = recycleParticle;
					recycleParticle = p;
					return false;
				}
				
				score.value += 1;
				
				AudioControl.playBounceParticle();
			}
			else if (p.y > 490)
			{
				p.recycleNext = recycleParticle;
				recycleParticle = p;
				// Remove from array
				return false;
			}
			
			// p remains in array
			return true;
		}
		
		public var lastX: Number = 0;
		
		public var blurBuffer1: BitmapData = new BitmapData(640, 480, true, 0);
		public var blurBuffer2: BitmapData = new BitmapData(640, 480, true, 0);
		public var colorTransform: ColorTransform = new ColorTransform(1, 1, 1, 0.8);
		
		public override function render (): void
		{
			var scrollX: Number = lastX - FP.camera.x;
			lastX = FP.camera.x;
			
			if (!focused && ballActive && lastBuffer) {
				rect.x = 0;
				rect.y = 0;
				rect.width = 640;
				rect.height = 480;
				
				FP.buffer.copyPixels(lastBuffer, rect, FP.zero);
				
				lastBuffer = FP.buffer;
				
				updateCount = 0;
				
				return;
			}
			
			rect.x = 0;
			rect.y = 0;
			rect.width = 640;
			rect.height = 480;
			
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
			
			FP.buffer.fillRect(rect, 0xFF000000 | (uint(r * 0x30)<<16) | (uint(g * 0x30)<<8) | (uint(b * 0x30)));
			
			//if (focused || !ballActive) {
				particles = particles.filter(updateParticlesFilter);
			//}
			
			var point: Point = new Point();
			
			// render past frame with alpha
			
			/*if (lastBuffer != null) {
				rect.x = 0;
				rect.y = 0;
				rect.width = 640;
				rect.height = 480;
				
				//FP.buffer.copyPixels(lastBuffer, rect, point, alphaBitmap, point, true);
				
				FP.buffer.merge(lastBuffer, rect, FP.zero, 0xA0, 0xA0, 0xA0, 0xA0);
			}*/
			
			lastBuffer = blurBuffer1;
			blurBuffer1 = blurBuffer2;
			blurBuffer2 = lastBuffer;
			
			point.x = scrollX;
			point.y = 0;
			
			blurBuffer1.fillRect(blurBuffer1.rect, 0);
			blurBuffer1.copyPixels(blurBuffer2, blurBuffer2.rect, point);
			blurBuffer1.colorTransform(blurBuffer1.rect, colorTransform);
			
			// render blocks
			
			rect.width = 32;
			rect.height = 16;
			
			for (var i: int = 0; i < 22; i++) {
				var ix: int = Math.floor(FP.camera.x / 32) + i - 1;
				
				for (var j: int = 0; j < 480/16; j++) {
					if (j > 7) {
						if (ix != -1 && ix != 20) { break; }
					}
					
					var lookup: String = ix + "x" + j;
					
					if (missing[lookup]) { continue; }
					
					rect.x = ix * 32 - FP.camera.x;
					rect.y = j * 16;
					
					point.x = ix * 32;
					point.y = j * 16;
					
					block.color = getColour(ix, j);
					
					block.render(point, FP.camera);
				}
			}
			
			// render particles
			
			rect.width = 4;
			rect.height = 4;
			
			Draw.setTarget(blurBuffer1, FP.camera);
			
			for each (var p: MyParticle in particles) {
				/*rect.x = p.x - FP.camera.x;
				rect.y = p.y;
				
				FP.buffer.fillRect(rect, p.colour);*/
				
				Draw.line(p.oldx, p.oldy, p.x, p.y, p.colour);
				//Draw.line(p.oldx + 1, p.oldy, p.x + 1, p.y, p.colour);
				
				//p.oldx = p.x;
				//p.oldy = p.y;
			}
			
			// render ball
			
			rect.width = 6;
			rect.height = 6;
			
			if (ballActive || ! canStart) {
				renderBall(ball.x - FP.camera.x, ball.y, oldBall.x - FP.camera.x, oldBall.y);
			} else {
				rect.x = ball.x - FP.camera.x;
				rect.y = ball.y;
				
				FP.buffer.fillRect(rect, 0xFFFFFFFF);
			}
			
			oldBall.x = ball.x;
			oldBall.y = ball.y;
			
			//for (i = 0; i < updateCount; i++) {
				/*rect.x = ball.x - FP.camera.x //- velocity.x * i;
				rect.y = ball.y //- velocity.y * i;
				
				blurBuffer1.fillRect(rect, 0xFFFFFFFF);*/
				
			/*	if (! ballActive) {
					break;
				}
			}*/
			
			updateCount = 0;
			
			// render lives
			
			for (i = 1; i <= lives; i++) {
				rect.x = 20 * i;
				rect.y = 16*8 + 20;
				
				FP.buffer.fillRect(rect, 0xFFFFFFFF);
			}
			
			FP.buffer.copyPixels(blurBuffer1, blurBuffer1.rect, FP.zero, null, null, true);
			
			// render paddle
			
			point.x = paddle;
			point.y = 480-8;
			
			paddleImage.render(point, FP.camera);
			
			point.x = 0;
			point.y = 0;
			
			scoreText.render(point, FP.camera);
			
			lastBuffer = FP.buffer;
		}
		
		public function addParticles (ix: int, iy: int): void
		{
			const bx: int = ix * 32;
			const by: int = iy * 16;
			
			var colour: uint = (0xFF000000 | getColour(ix, iy));
			
			for (var i: int = 0; i < 8; i++) {
				for (var j: int = 0; j < 4; j++) {
					const px: int = bx + i*4 + 2;
					const py: int = by + j*4 + 2;
					
					var dx: Number = (px - ball.x - 2);
					var dy: Number = (py - ball.y - 2);
					
					dx = dx * (Math.random() + 1) * 0.1 + velocity.x * 0.2;
					dy = dy * (Math.random() + 1) * 0.1 + velocity.y * 0.2;
					
					var p: MyParticle;
					
					if (recycleParticle) {
						p = recycleParticle;
						recycleParticle = p.recycleNext;
						p.recycleNext = null;
					} else {
						p = new MyParticle;
					}
					
					p.x = p.oldx = px;
					p.y = p.oldy = py;
					p.dx = dx;
					p.dy = dy;
					p.colour = colour;
					
					particles.push(p);
				}
			}
		}
		
		public function renderBall(x1:int, y1:int, x2:int, y2:int):void
		{
			// get the drawing positions
			/*x1 -= _camera.x;
			y1 -= _camera.y;
			x2 -= _camera.x;
			y2 -= _camera.y;*/
			
			rect.width = 6;
			rect.height = 6;
			
			// get the drawing difference
			var screen:BitmapData = blurBuffer1,
				X:Number = Math.abs(x2 - x1),
				Y:Number = Math.abs(y2 - y1),
				xx:int,
				yy:int;
			
			// draw a single pixel
			if (X == 0)
			{
				if (Y == 0)
				{
					rect.x = x1; rect.y = y1; screen.fillRect(rect, 0xFFFFFFFF);
					return;
				}
				// draw a straight vertical line
				yy = y2 > y1 ? 1 : -1;
				while (y1 != y2)
				{
					rect.x = x1; rect.y = y1; screen.fillRect(rect, 0xFFFFFFFF);
					y1 += yy;
				}
				rect.x = x2; rect.y = y2; screen.fillRect(rect, 0xFFFFFFFF);
				return;
			}
			
			if (Y == 0)
			{
				// draw a straight horizontal line
				xx = x2 > x1 ? 1 : -1;
				while (x1 != x2)
				{
					rect.x = x1; rect.y = y1; screen.fillRect(rect, 0xFFFFFFFF);
					x1 += xx;
				}
				rect.x = x2; rect.y = y2; screen.fillRect(rect, 0xFFFFFFFF);
				return;
			}
			
			xx = x2 > x1 ? 1 : -1;
			yy = y2 > y1 ? 1 : -1;
			var c:Number = 0,
				slope:Number;
			
			if (X > Y)
			{
				slope = Y / X;
				c = .5;
				while (x1 != x2)
				{
					rect.x = x1; rect.y = y1; screen.fillRect(rect, 0xFFFFFFFF);
					x1 += xx;
					c += slope;
					if (c >= 1)
					{
						y1 += yy;
						c -= 1;
					}
				}
				rect.x = x2; rect.y = y2; screen.fillRect(rect, 0xFFFFFFFF);
				return;
			}
			else
			{
				slope = X / Y;
				c = .5;
				while (y1 != y2)
				{
					rect.x = x1; rect.y = y1; screen.fillRect(rect, 0xFFFFFFFF);
					y1 += yy;
					c += slope;
					if (c >= 1)
					{
						x1 += xx;
						c -= 1;
					}
				}
				rect.x = x2; rect.y = y2; screen.fillRect(rect, 0xFFFFFFFF);
				return;
			}
		}
		
	}
}
