package
{
	import net.flashpunk.*;
	import net.flashpunk.utils.Data;
	
	[SWF(width = "640", height = "480", backgroundColor="#000000")]
	public class Main extends Engine
	{
		public function Main() 
		{
			Data.load("getout");
			
			AudioControl.init();
			
			super(640, 480, 60, true);
			
			//Kongregate.connect(this);
			Mochi.connect(this);
			
			FP.world = new MainMenu();
		}
	}
}
