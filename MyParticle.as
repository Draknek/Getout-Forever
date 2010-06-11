package
{
	public class MyParticle 
	{
		public var x: Number = 0;
		public var y: Number = 0;
		public var oldx: Number = 0;
		public var oldy: Number = 0;
		public var dx: Number = 0;
		public var dy: Number = 0;
		
		public var colour: uint = 0xFFFF0000;
		
		public function MyParticle(_x: Number, _y: Number, _dx: Number, _dy: Number, _c: uint) 
		{
			x = _x + 2;
			y = _y + 2;
			
			dx = _dx;
			dy = _dy;
			
			colour = _c;
		}
		
	}
}
