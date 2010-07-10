
package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	import flash.display.LoaderInfo;
	import flash.utils.getDefinitionByName;

	public class Preloader extends World
	{
		private var text: Text;
		
		private var nextClassName: String;
		
		private var mustClick: Boolean = false;
		
		public var bgColour: Number = 0;
		
		public function Preloader (_next: String)
		{
			nextClassName = _next;
			
			text = new Text("0%", 320, 260, 300);
			
			text.align = "center";
			
			text.x = 320 - text.width * 0.5;
		}

		public override function update (): void
		{
			bgColour += 0.01;
			
			if (hasLoaded())
			{
				if (mustClick) {
					if (Input.mousePressed) {
						startup();
					}
				} else {
					startup();
				}
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
			
			if (hasLoaded())
			{
				text.scale = 2;
				
				text.text = "Click to start";
				
				text.x = 320 - text.width * 0.5;
				text.y = 240 - text.height * 0.5;
			}
			else
			{
				FP.rect.x = 68;
				FP.rect.y = 228;
				FP.rect.width = 504;
				FP.rect.height = 24;
				
				FP.buffer.fillRect(FP.rect, 0xFFFFFFFF);
				
				var p:Number = (this.loaderInfo.bytesLoaded / this.loaderInfo.bytesTotal);
				
				FP.rect.x = 70;
				FP.rect.y = 230;
				FP.rect.width = p * 500;
				FP.rect.height = 20;
				
				FP.buffer.fillRect(FP.rect, 0xFF000000);
				
				text.text = int(p * 100) + "%";
			}
			
			FP.point.x = 0;
			FP.point.y = 0;
			text.render(FP.point, FP.zero);
		}
		
		private function hasLoaded (): Boolean {
			return (FP.stage.loaderInfo.bytesLoaded >= FP.stage.loaderInfo.bytesTotal);
		}
		
		private function startup (): void
		{
			var mainClass:Class = getDefinitionByName(nextClassName) as Class;
			
			FP.world = new mainClass() as World;
		}
		
		private function get loaderInfo (): LoaderInfo
		{
			return FP.engine.loaderInfo;
		}
	}
}


