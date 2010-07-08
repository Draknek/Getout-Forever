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
		
		[Embed(source="audio/bounce-paddle.mp3")]
		public static var bouncePaddleSfx:Class;
		
		[Embed(source="audio/bounce-block.mp3")]
		public static var bounceBlockSfx:Class;
		
		[Embed(source="audio/rain.mp3")]
		public static var bounceParticleSfx:Class;
		
		[Embed(source="audio/death.mp3")]
		public static var deathSfx:Class;
		
		[Embed(source="audio/music3.mp3")]
		public static var music2Sfx: Class;
		
		[Embed(source="audio/music2.mp3")]
		public static var music1Sfx: Class;
		
		/*private var soundOnImage : Bitmap;
		private var soundOffImage : Bitmap;*/
		
		private static var bouncePaddle : Sound = new bouncePaddleSfx();
		private static var bounceBlock : Sound = new bounceBlockSfx();
		private static var bounceParticle : Sound = new bounceParticleSfx();
		private static var death : Sound = new deathSfx();
		private static var music : Sound = new music1Sfx();
		
		private static var musicChannel : SoundChannel;
		private static var rainChannel : SoundChannel;
		
		private static var _rainVolume : Number = 0;
		
		public static function get rainVolume (): Number {
			return _rainVolume;
		}
		
		public static function set rainVolume (value: Number): void {
			if (value > 0.5) { value = 0.5; }
			else if (value < 0.0) { value = 0.0; }
			
			if (value == _rainVolume) { return; }
			
			_rainVolume = value;
			
			var transform: SoundTransform = rainChannel.soundTransform;
			
			transform.volume = _rainVolume;
			
			rainChannel.soundTransform = transform;
		}
		
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
		
		public static function playMusic () : void
		{
			if (! mute)
			{
				// MP3 encoding annoyingly puts empty space at the beginning: 55ms in this case
				musicChannel = music.play(55, int.MAX_VALUE);
				
				rainChannel = bounceParticle.play(1000, int.MAX_VALUE, new SoundTransform(0, 0));
			}
		}
		
		public static function stopMusic (): void
		{
			if (musicChannel) {
				musicChannel.stop();
			}
			
			if (rainChannel) {
				rainChannel.stop();
			}
		}
		
		public static function switchMusic (): void
		{
			stopMusic();
			
			music = new music2Sfx();
			
			playMusic();
		}
		
		public static function playBouncePaddle () : void
		{
			if (! mute)
			{
				var i : int = (Math.random() * 4);
				
				var channel : SoundChannel = bouncePaddle.play(i * 1000);
				
				if (channel)
				{
					var timer : Timer = new Timer(600);
					timer.addEventListener(TimerEvent.TIMER, runMe);
					timer.start();
					
					function runMe():void{
					    channel.stop();
					}
				}
			}
		}
		
		public static function playBounceBlock () : void
		{
			if (! mute)
			{
				var i : int = (Math.random() * 4);
				
				var channel : SoundChannel = bounceBlock.play(i * 1000);
				
				if (channel)
				{
					var timer : Timer = new Timer(600);
					timer.addEventListener(TimerEvent.TIMER, runMe);
					timer.start();
					
					function runMe():void{
					    channel.stop();
					}
				}
			}
		}
		
		public static function playBounceParticle () : void
		{
			if (! mute)
			{
				/*var i : int = (Math.random() * 4);
				
				var channel : SoundChannel = bounceParticle.play(i * 125);
				
				if (channel)
				{
					var timer : Timer = new Timer(100);
					timer.addEventListener(TimerEvent.TIMER, runMe);
					timer.start();
					
					function runMe():void{
					    channel.stop();
					}
				}*/
				
				rainVolume += 0.1;
			}
		}
		
		public static function playDeath () : void
		{
			if (! mute)
			{
				death.play();
			}
		}
		
	}
}

