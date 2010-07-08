package
{
	import flash.display.*;

	import mochi.as3.*;
	
	public class Mochi
	{
		public static function connect (obj: DisplayObjectContainer): void
		{
			MochiServices.connect("ea7f432cc36562ee", obj);
		}
		
		public static function startPlay (): void
		{
			MochiEvents.startPlay();
		}

		public static function endPlay (): void
		{
			MochiEvents.endPlay();
		}
		
		public static function submitScore (score: int): void
		{
			var o:Object = { n: [7, 13, 14, 4, 2, 5, 5, 1, 6, 9, 8, 0, 11, 6, 14, 4], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
			var boardID:String = o.f(0,"");
			MochiScores.showLeaderboard({boardID: boardID, score: score});
		}
	}
}


