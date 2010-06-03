package
{
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.utils.*;
	
	public class AudioControl extends Sprite
	{
		/*[Embed(source="images/sound-on.png")]
		public static var soundOnImageSrc:Class;
		
		[Embed(source="images/sound-off.png")]
		public static var soundOffImageSrc:Class;*/
		
		public static var mute : Boolean = false;
		
		[Embed(source="bounces.mp3")]
		public static var bounceSfx:Class;
		
		/*private var soundOnImage : Bitmap;
		private var soundOffImage : Bitmap;*/
		
		private static var bounce : Sound = new bounceSfx();
		
		public function AudioControl ()
		{
			/*soundOnImage = new soundOnImageSrc();
			soundOffImage = new soundOffImageSrc();
			
			addChild(soundOffImage);
			addChild(soundOnImage);
			
			soundOffImage.visible = mute;
			soundOnImage.visible = ! mute;
			
			addEventListener(MouseEvent.CLICK, toggleSound);
			
			music = new musicSrc();
			winSounds = new winSoundsSrc();
			wrong = new wrongSrc();
			gameOver = new gameOverSrc();
			
			playMusic();*/
		}

		/*public function toggleSound (e : Event) : void
		{
			mute = ! mute;
			
			soundOffImage.visible = mute;
			soundOnImage.visible = ! mute;
			
			if (mute) {
				stopMusic();
			} else {
				playMusic();
			}
		}*/
		
		/*public static function playMusic () : void
		{
			if (! mute)
			{
				musicChannel = music.play();
				
				// set up looping variables based on your mp3 encoding software
				var leader:Number = 55;    // milliseconds gap at the start of the mp3
				//var follower:Number = 50;  // milliseconds gap at the end of the mp3
				var placeToStop:Number = 32289;
				
				if (musicSyncTimer)
				{
					musicSyncTimer.stop();
				}
				
				// run interval to constantly check the position of the mp3
				// and restart after the initial mp3 gap.
				musicSyncTimer = new Timer(1);
				musicSyncTimer.addEventListener(TimerEvent.TIMER, runMe);
				musicSyncTimer.start();
				
				function runMe():void{
				    if (musicChannel.position > placeToStop) {
				        musicChannel.stop();
				        musicChannel = music.play(leader);
				    }
				}
			}
		}*/
		
		/*public static function stopMusic (): void
		{
			if (musicChannel) {
				musicChannel.stop();
			}
			
			if (musicSyncTimer)
			{
				musicSyncTimer.stop();
				musicSyncTimer = null;
			}
		}*/
		
		public static function playBounce () : void
		{
			if (! mute)
			{
				var i : int = (Math.random() * 7);
				
				var channel : SoundChannel = bounce.play(i * 2000);
				
				if (channel)
				{
					var timer : Timer = new Timer(500);
					timer.addEventListener(TimerEvent.TIMER, runMe);
					timer.start();
					
					function runMe():void{
					    channel.stop();
					}
				}
			}
		}
	}
}

