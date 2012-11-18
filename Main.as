package
{
	import net.flashpunk.*;
	import net.flashpunk.utils.*;
	
	import flash.system.*;
	
	[SWF(width = "640", height = "480", backgroundColor="#000000")]
	public class Main extends Engine
	{
		public static var touchscreen:Boolean = false;
		public static var isAndroid:Boolean = false;
		public static var isIOS:Boolean = false;
		public static var isPlaybook:Boolean = false;
		
		public static var mouseX:Number = 0.0;
		
		public function Main() 
		{
			if (Capabilities.manufacturer.toLowerCase().indexOf("ios") != -1) {
				isIOS = true;
				touchscreen = true;
			}
			else if (Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0) {
				isAndroid = true;
				touchscreen = true;
			} else if (Capabilities.os.indexOf("QNX") >= 0) {
				isPlaybook = true;
				touchscreen = true;
			}
			
			var w:int = 640;
			var h:int = 480;
			
			if (touchscreen) {
				w = stage.fullScreenWidth;
				h = stage.fullScreenHeight;
			}
			
			super(w, h, 60, true);
			
			//Kongregate.connect(this);
			Mochi.connect(this);
			
			FP.world = new Preloader("MainMenu");
			
			//FP.console.enable();
			
			Main.mouseX = w*0.5;
		}
		
		public override function update ():void
		{
			if (! touchscreen || Input.mouseDown) {
				Main.mouseX = Input.mouseX;
			}
			
			super.update();
		}
	}
}
