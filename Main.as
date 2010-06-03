package
{
	import net.flashpunk.*;
	
	[SWF(width = "640", height = "480", backgroundColor="#000000")]
	public class Main extends Engine
	{
		public static var score: NumberTextField;
		
		public function Main() 
		{
			score = new NumberTextField(320, 160, "", "center", 32);
			
			super(640, 480, 60, true);
			
			Kongregate.connect(this);
			
			FP.world = new Level();
			
			addChild(score);
		}
	}
}
