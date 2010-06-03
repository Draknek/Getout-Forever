package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.geom.*;
	import flash.events.*;
	import flash.ui.Mouse;
	
	public class Level extends World
	{
		[Embed(source="block.png")]
		public static var blockGfx: Class;
		
		[Embed(source="paddle.png")]
		public static var paddleGfx: Class;
		
		public var block: Image = new Image(blockGfx);
		
		public var paddleImage: Image = new Image(paddleGfx);
		
		public var missing: Object = {};
		
		public var rect: Rectangle = new Rectangle();
		
		public var ball: Point = new Point(400, 300);
		public var velocity: Point = new Point(3.5, 3);
		public var paddle: Number = 320 - 64;
		
		public var freeCamera: Boolean = false;
		
		public var focused: Boolean = false;
		
		public function Level()
		{
			Main.score.value = 0;
			
			/*for (var j: int = 8; j < 480/16; j++) {
				missing["-1x" + j] = true;
				missing["20x" + j] = true;
			}*/
		}
		
		public override function begin (): void
		{
			FP.stage.addEventListener(Event.ACTIVATE, focusGain);
			FP.stage.addEventListener(MouseEvent.MOUSE_DOWN, focusGain);
			FP.stage.addEventListener(Event.DEACTIVATE, focusLost);
		}
		
		private function focusGain(e:Event):void
		{
			focused = true;
			Mouse.hide();
		}
		
		private function focusLost(e:Event):void
		{
			focused = false;
			Mouse.show();
		}
		
		public override function update (): void
		{
			if (! focused) { return; }
			
			paddle = Input.mouseX - 64 + FP.camera.x;
			
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
			
			if (ball.y < 0) { velocity.y *= -1; ball.y = 0; }
			else if (ball.y > 480-6-8) {
				var paddleDiff: Number = ball.x - paddle;
				
				if (paddleDiff > -6 && paddleDiff < 128) {
					velocity.x = ((paddleDiff + 6) - 67) * 0.05;
					
					if (freeCamera) {
						velocity.x += (Input.mouseX - 320) * 0.05;
					}
					
					velocity.y *= -1;
					velocity.y -= 0.05;
					ball.y = 480-6-8;
				} else if (ball.y > 480) {
					ball.y = 200;
				}
			}
			
			var lookup: String;
			var hit: Boolean = false;
			
			// check up/down
			
			var ix: int = ix1;
			var iy: int = iy2;
			
			if ((iy < 8 || ix == -1 || ix == 20) && ! missing[lookup = ix + "x" + iy]) {
				missing[lookup] = true;
				Main.score.value += 10;
				
				velocity.y *= -1;
				
				ix = ix2;
				
				if ((iy < 8 || ix == -1 || ix == 20) && ! missing[lookup = ix + "x" + iy]) {
					missing[lookup] = true;
					Main.score.value += 10;
				}
				
				hit = true;
			}
			
			// check left/right
			
			ix = ix2;
			iy = iy1;
			
			if ((iy < 8 || ix == -1 || ix == 20) && ! missing[lookup = ix + "x" + iy]) {
				missing[lookup] = true;
				Main.score.value += 10;
				
				velocity.x *= -1;
				
				iy = iy2;
				
				if ((iy < 8 || ix == -1 || ix == 20) && ! missing[lookup = ix + "x" + iy]) {
					missing[lookup] = true;
					Main.score.value += 10;
				}
				
				hit = true;
			}
			
			// TODO: check diagonal if hit is false?
			
			if (hit && Kongregate.api) {
				Kongregate.api.stats.submit("Score", Main.score.value);
			}
			
			if (ball.x < -32 || ball.x > 640+32-6) { freeCamera = true; }
			
			/*if (ball.x - FP.camera.x < 0) { ball.x = FP.camera.x; velocity.x = Math.abs(velocity.x); }
			else if (ball.x - FP.camera.x > 640-6) { ball.x = FP.camera.x + 640-6; velocity.x = -Math.abs(velocity.x); }*/
			
		}
		
		public override function render (): void
		{
			// render blocks
			
			rect.width = 32;
			rect.height = 16;
			
			var point: Point = new Point();
			
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
					
					var id: int = Math.floor(ix / 20) * 98317 + Math.floor(j / 2) * 393241 + 12289;
					
					var colour: uint = /*(0xFF000000 |*/( uint(id * 374321));
					
					//FP.buffer.fillRect(rect, colour);
					
					block.color = colour;
					
					block.render(point, FP.camera);
				}
			}
			
			// render ball
			
			rect.width = 6;
			rect.height = 6;
			
			rect.x = ball.x - FP.camera.x;
			rect.y = ball.y;
			
			FP.buffer.fillRect(rect, 0xFFFFFFFF);
			
			// render paddle
			
			point.x = paddle;
			point.y = 480-8;
			
			paddleImage.render(point, FP.camera);
		}
		
	}
}
