package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.events.*;
	import flash.ui.Mouse;
	
	public class Level extends World
	{
		[Embed(source="MODENINE.TTF", fontName='modenine', mimeType='application/x-font')]
		public static var modeNineFont : Class;
		
		[Embed(source="images/large/block.png")]
		public static const blockGfxLarge: Class;
		[Embed(source="images/large/paddle.png")]
		public static const paddleGfxLarge: Class;
		
		[Embed(source="images/normal/block.png")]
		public static const blockGfxNormal: Class;
		[Embed(source="images/normal/paddle.png")]
		public static const paddleGfxNormal: Class;
		
		public static const so:SharedObject = SharedObject.getLocal("getoutforever", "/");
		
		public var block: Image;
		public var paddleImage: Image;
		
		public var missing: Object = {};
		
		public var rect: Rectangle = new Rectangle();
		
		public var ball: Point;
		public var oldBall: Point;
		public var velocity: Point = new Point(3.5, 3);
		public var paddle: Number = 320 - 64;
		
		public var freeCamera: Boolean = false;
		
		public var focused: Boolean = false;
		public var ballActive: Boolean = false;
		public var canStart: Boolean = true;
		public var gameover: Boolean = false;
		
		public var paused:Boolean = false;
		
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
		public var prevScore: Text;
		
		public var submitButton: Button;
		public var replayButton: Button;
		public var menuButton: Button;
		public var exitButton: Button;
		
		public var minX: Number = -320;
		public var maxX: Number = 320;
		
		public var BLOCK_W: int = 32;
		public var BLOCK_H: int = 16;
		
		public function Level()
		{
			if (FP.width > 800) {
				BLOCK_W = 64;
				BLOCK_H = 32;
				
				block = new Image(blockGfxLarge);
				paddleImage = new Image(paddleGfxLarge);
			} else {
				BLOCK_W = 32;
				BLOCK_H = 16;
				
				block = new Image(blockGfxNormal);
				paddleImage = new Image(paddleGfxNormal);
			}
			
			ball = new Point(400, FP.height - (paddleImage.height + 6));
			oldBall = new Point(400, FP.height - (paddleImage.height + 6));
			
			AudioControl.startGame();
			
			focusGain();
			
			Text.font = "modenine";
			Text.size = 40;
			Text.align = "center";
			
			scoreText = new Text("0", FP.width*0.5 - 50, 160, 100);
			scoreText.scrollX = 0;
			scoreText.y = BLOCK_H*8+10;
			
			if (! so.data.highscore) so.data.highscore = 0;
			
			
			prevScore = new Text("", FP.width*0.5 - 250, 160, 500);
			prevScore.scrollX = 0;
			prevScore.size = 30;
			//prevScore.x = FP.width*0.5 - prevScore.width*0.5;
			prevScore.y = BLOCK_H*8+10 + 50;
			
			
			score = new NumberString();
			
			score.bind(scoreText, "text");
			
			colourOffset = Math.random() * int.MAX_VALUE;
			
			var lowest:int = 18;
			
			missing["-1x"+lowest] = true;
			missing[int(FP.width / BLOCK_W)+"x"+lowest] = true;
			
			alphaBitmap = new BitmapData(FP.width, FP.height, true, 0xA0000000);
			
			//AudioControl.playMusic();
			
			Mochi.startPlay();
		}
		
		public function getColour (ix: int, iy: int): uint
		{
			var colour: uint = Math.floor(ix / (FP.width / BLOCK_W)) * 98317 + Math.floor(iy / 2) * 393241 + 12289 + colourOffset;
			
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
			FP.camera.x = 0;
			
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
			if (replayButton) FP.engine.removeChild(replayButton);
			if (menuButton) FP.engine.removeChild(menuButton);
			if (exitButton) FP.engine.removeChild(exitButton);
		}
		
		private function mouseClick(e:Event):void
		{
			if (gameover) { return; }
			
			if (canStart) {
				canStart = false;
				ballActive = true;
				
				velocity.y = -3.0 - 0.5 * (Math.abs(velocity.y) - 3.0);
				velocity.x = 3.5 * Math.abs(velocity.y) / 3.0
				
				if (ball.x - FP.camera.x < FP.width*0.5 - 3) {
					velocity.x *= -1;
				}
				
				if (freeCamera) {
					velocity.x += (Input.mouseX - FP.width*0.5) * 0.025;
				}
			}
			
			focusGain();
		}
		
		private function focusGain(e:Event = null):void
		{
			if (! focused) {
				AudioControl.playMusic();
			}
			
			focused = true;
			if (! gameover) {
				Mouse.hide();
			}
			
		}
		
		private function focusLost(e:Event = null):void
		{
			focused = false;
			Mouse.show();
			AudioControl.stopMusic();
		}
		
		public override function update (): void
		{
			if (Input.pressed(Key.M)) {
				AudioControl.toggleSound();
			}
			
			if (Input.pressed(Key.SPACE)) {
				paused = ! paused;
			}
			
			if (paused) return;
			
			updateCount++;
			
			if (focused) {
				AudioControl.rainVolume *= 0.99;
			}
			
			bgColour += 0.002;
			
			if (gameover) {
				if (freeCamera) {
					if (FP.camera.x <= minX) {
						velocity.x = Math.abs(velocity.x);
					} else if (FP.camera.x >= maxX) {
						velocity.x = -Math.abs(velocity.x);
					}
					
					FP.camera.x += velocity.x;
				}
				return;
			}
			
			if (! focused && ballActive) { return; }
			
			paddle += (Input.mouseX - paddleImage.width*0.5 + FP.camera.x - paddle)*0.1;
			
			if (! ballActive) {
				if (! canStart) {
					var dx: Number = paddle + paddleImage.width*0.5 - 3 - ball.x;
					var dy: Number = FP.height - (6 + paddleImage.height) - ball.y;
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
				
				ball.x = paddle + paddleImage.width*0.5 - 3;
				ball.y = FP.height - (paddleImage.height + 6);
				
				return;
			}
			
			if (freeCamera) {
				FP.camera.x += (Input.mouseX - FP.width*0.5) * 0.05;
			}
			
			ball.x += velocity.x;
			ball.y += velocity.y;
			
			// collide against blocks
			
			var tmp: int;
			
			var ix1: int = Math.floor(ball.x / BLOCK_W);
			var ix2: int = Math.floor((ball.x + 6) / BLOCK_W);
			
			if (velocity.x < 0) {
				tmp = ix1;
				ix1 = ix2;
				ix2 = tmp;
			}
			
			var iy1: int = Math.floor(ball.y / BLOCK_H);
			var iy2: int = Math.floor((ball.y + 6) / BLOCK_H);
			
			if (velocity.y < 0) {
				tmp = iy1;
				iy1 = iy2;
				iy2 = tmp;
			}
			
			// collide against floor/ceiling
			
			var bounced: Boolean = false;
			
			if (ball.y < 0) { velocity.y *= -1; ball.y = 0; bounced = true; }
			else if (ball.y > FP.height-6-paddleImage.height) {
				var paddleDiff: Number = ball.x - paddle;
				
				if (paddleDiff > -6 && paddleDiff < paddleImage.width) {
					velocity.x = ((paddleDiff + 6) - (paddleImage.width+6)*0.5) * 0.05 * Math.abs(velocity.y) / 3.0;
					
					if (freeCamera) {
						velocity.x += (Input.mouseX - FP.width*0.5) * 0.025;
					}
					
					velocity.y *= -1;
					velocity.y -= 0.05;
					ball.y = FP.height-6-paddleImage.height;
					
					bounced = true;
				} else if (ball.y > FP.height) {
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
						ball.x = FP.camera.x + 20 * lives - 10;
						ball.y = BLOCK_H*8 + 10;
						oldBall.x = ball.x;
						oldBall.y = ball.y;
						velocity.x = 1;
						
						lives--;
					} else {
						gameover = true;
						
						Mochi.endPlay();
						
						Mouse.show();
						
						AudioControl.fadeOut();
						
						replayButton = new Button("Replay", 400)
						FP.engine.addChild(replayButton);
						replayButton.addEventListener(MouseEvent.CLICK, function (): void {
							//Mochi.closeScores();
							FP.world = new Level();
						});
						
						/*exitButton = new Button("Exit", 475)
						FP.engine.addChild(exitButton);
						exitButton.addEventListener(MouseEvent.CLICK, function (): void {
							var stage:* = FP.stage;
							stage.nativeWindow.close();
						});*/
						
						if (!prevScore.text) prevScore.text = "High score: " + so.data.highscore;
						
						velocity.x /= Math.abs(velocity.x);
						velocity.x *= 0.5;
						
						minX = 0;
						maxX = 19;
						
						for (var s: String in missing) {
							s = s.split("x")[0];
							
							var i: int = int(s);
							
							if (i < minX) {
								minX = i;
							}
							
							if (i > maxX) {
								maxX = i;
							}
						}
						
						maxX += 1;
						
						minX *= BLOCK_W;
						maxX *= BLOCK_W;
						
						minX -= 320;
						maxX -= 320;
					}
				}
			}
			
			var lookup: String;
			var hit: Boolean = false;
			
			// check up/down
			
			var ix: int = ix1;
			var iy: int = iy2;
			
			if (((iy < 8 && iy > -1) || ix == -1 || ix == int(FP.width / BLOCK_W)) && ! missing[lookup = ix + "x" + iy]) {
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
			
			if (((iy < 8 && iy > -1) || ix == -1 || ix == int(FP.width / BLOCK_W)) && ! missing[lookup = ix + "x" + iy]) {
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
			
			if (! hit && ((iy < 8 && iy > -1) || ix == -1 || ix == int(FP.width / BLOCK_W)) && ! missing[lookup = ix + "x" + iy]) {
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
			
			if (score.value > so.data.highscore) {
				prevScore.text = "New record!";
				so.data.highscore = score.value;
				so.flush();
			}
			
			if (bounced) {
				AudioControl.playBouncePaddle();
			}
			
			if (! freeCamera) {
				if (ball.x < -32 || ball.x > FP.width+32-6) {
					freeCamera = true;
					AudioControl.switchMusic();
				}
			}
			
			/*if (ball.x - FP.camera.x < 0) { ball.x = FP.camera.x; velocity.x = Math.abs(velocity.x); }
			else if (ball.x - FP.camera.x > FP.width-6) { ball.x = FP.camera.x + FP.width-6; velocity.x = -Math.abs(velocity.x); }*/
		}
		
		private function updateParticlesFilter (p: MyParticle, index: int, arr: Vector.<MyParticle>): Boolean
		{
			p.oldx = p.x;
			p.oldy = p.y;
			
			p.x += p.dx;
			p.y += p.dy;
			
			//p.dx *= 0.99;
			p.dy += 0.2;
			
			if (p.y > FP.height - paddleImage.height && p.x > paddle && p.x < paddle + paddleImage.width) {
				p.dy = -Math.abs(p.dy) * 0.5;
				p.oldy = FP.height-paddleImage.height;
				p.y = p.oldy + p.dy;
				
				if (p.dy > -1) {
					p.recycleNext = recycleParticle;
					recycleParticle = p;
					return false;
				}
				
				score.value += 1;
				
				AudioControl.playRain();
			}
			else if (p.y > FP.height + 10)
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
		
		public var blurBuffer1: BitmapData = new BitmapData(FP.width, FP.height, true, 0);
		public var blurBuffer2: BitmapData = new BitmapData(FP.width, FP.height, true, 0);
		public var colorTransform: ColorTransform = new ColorTransform(1, 1, 1, 0.8);
		
		public override function render (): void
		{
			var scrollX: Number = lastX - FP.camera.x;
			lastX = FP.camera.x;
			
			if (!focused && ballActive && lastBuffer) {
				rect.x = 0;
				rect.y = 0;
				rect.width = FP.width;
				rect.height = FP.height;
				
				FP.buffer.copyPixels(lastBuffer, rect, FP.zero);
				
				lastBuffer = FP.buffer;
				
				updateCount = 0;
				
				return;
			}
			
			rect.x = 0;
			rect.y = 0;
			rect.width = FP.width;
			rect.height = FP.height;
			
			var t: Number = (bgColour) % 6;
			
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
			
			FP.buffer.fillRect(rect, 0xFF000000 | (uint(r * 0x50)<<16) | (uint(g * 0x50)<<8) | (uint(b * 0x50)));
			
			//if (focused || !ballActive) {
			if (! paused) {
				particles = particles.filter(updateParticlesFilter);
			}
			
			var point: Point = new Point();
			
			// render past frame with alpha
			
			/*if (lastBuffer != null) {
				rect.x = 0;
				rect.y = 0;
				rect.width = FP.width;
				rect.height = FP.height;
				
				//FP.buffer.copyPixels(lastBuffer, rect, point, alphaBitmap, point, true);
				
				FP.buffer.merge(lastBuffer, rect, FP.zero, 0xA0, 0xA0, 0xA0, 0xA0);
			}*/
			
			if (! paused) {
				lastBuffer = blurBuffer1;
				blurBuffer1 = blurBuffer2;
				blurBuffer2 = lastBuffer;
			
				point.x = scrollX;
				point.y = 0;
			
				blurBuffer1.fillRect(blurBuffer1.rect, 0);
				blurBuffer1.copyPixels(blurBuffer2, blurBuffer2.rect, point);
				blurBuffer1.colorTransform(blurBuffer1.rect, colorTransform);
			}
			
			// render blocks
			
			for (var i: int = 0; i < FP.width/BLOCK_W + 2; i++) {
				var ix: int = Math.floor(FP.camera.x / BLOCK_W) + i - 1;
				
				for (var j: int = 0; j < FP.height/BLOCK_H; j++) {
					if (j > 7) {
						if (ix != -1 && ix != int(FP.width / BLOCK_W)) { break; }
					}
					
					var lookup: String = ix + "x" + j;
					
					if (missing[lookup]) { continue; }
					
					point.x = ix * BLOCK_W;
					point.y = j * BLOCK_H;
					
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
			
			if (ballActive || ! canStart || ball.y != oldBall.y) {
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
				rect.x = 20 * i - 10;
				rect.y = BLOCK_H*8 + 10;
				
				FP.buffer.fillRect(rect, 0xFFFFFFFF);
			}
			
			FP.buffer.copyPixels(blurBuffer1, blurBuffer1.rect, FP.zero, null, null, true);
			
			// render paddle
			
			point.x = paddle;
			point.y = FP.height-paddleImage.height;
			
			paddleImage.render(point, FP.camera);
			
			point.x = 0;
			point.y = 0;
			
			scoreText.render(point, FP.camera);
			
			point.x = 0;
			point.y = 0;
			
			if (prevScore) prevScore.render(point, FP.camera);
			
			lastBuffer = FP.buffer;
		}
		
		public function addParticles (ix: int, iy: int): void
		{
			const bx: int = ix * BLOCK_W;
			const by: int = iy * BLOCK_H;
			
			var colour: uint = (0xFF000000 | getColour(ix, iy));
			
			for (var i: int = 0; i < 8; i++) {
				for (var j: int = 0; j < 4; j++) {
					const px: int = bx + i*8 + 4;
					const py: int = by + j*8 + 4;
					
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
