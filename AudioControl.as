package
{
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.utils.*;
	
	import net.flashpunk.FP;
	import net.flashpunk.utils.Data;
	
	public class AudioControl extends Sprite
	{
		public static var mute : Boolean = false;
		
		[Embed(source="audio/bounce-paddle.mp3")]
		public static var bouncePaddleSfx:Class;
		
		[Embed(source="audio/bounce-block.mp3")]
		public static var bounceBlockSfx:Class;
		
		[Embed(source="audio/rain.mp3")]
		public static var rainSfx:Class;
		
		[Embed(source="audio/death.mp3")]
		public static var deathSfx:Class;
		
		[Embed(source="audio/music3.mp3")]
		public static var gentleMusicSfx: Class;
		
		[Embed(source="audio/music2.mp3")]
		public static var actionMusicSfx: Class;
		
		private static var bouncePaddle : Sound = new bouncePaddleSfx();
		private static var bounceBlock : Sound = new bounceBlockSfx();
		private static var rain : Sound = new rainSfx();
		private static var death : Sound = new deathSfx();
		private static var actionMusic : Sound = new actionMusicSfx();
		private static var gentleMusic : Sound = new gentleMusicSfx();
		private static var music : Sound;
		
		private static var musicChannel : SoundChannel;
		private static var rainChannel : SoundChannel;
		
		private static var _rainVolume : Number = 0;
		
		private static var fadeTimer: Timer = null;
		
		private static var musicPosition: Number = 0;
		
		public static function get rainVolume (): Number {
			return _rainVolume;
		}
		
		public static function set rainVolume (value: Number): void {
			if (value > 1.0) { value = 1.0; }
			else if (value < 0.0) { value = 0.0; }
			
			if (value == _rainVolume) { return; }
			
			if (! rainChannel) { return; }
			
			_rainVolume = value;
			
			var transform: SoundTransform = rainChannel.soundTransform;
			
			transform.volume = _rainVolume;
			
			rainChannel.soundTransform = transform;
		}
		
		public static function init (): void
		{
			Data.load("getout");

			mute = Data.readBool("mute", false);
		}

		public static function toggleSound (e : * = null) : void
		{
			mute = ! mute;
			
			if (mute) {
				stopMusic();
			} else if (FP.world is Level) {
				playMusic();
			}
			
			Data.writeBool("mute", mute);
			
			Data.save("getout");
		}
		
		public static function playMusic () : void
		{
			stopMusic();
			
			if (! music) { return; }
			
			if (! mute)
			{
				if (musicPosition < 55) {
					musicChannel = music.play(55, int.MAX_VALUE);
				} else {
					musicChannel = music.play(musicPosition);
					
					musicChannel.addEventListener(Event.SOUND_COMPLETE, onComplete);
					
					function onComplete(e:Event = null): void {
						musicChannel = music.play(55, int.MAX_VALUE);
					}
				}
				
				rainChannel = rain.play(1000, int.MAX_VALUE, new SoundTransform(rainVolume, 0));
			}
		}
		
		public static function stopMusic (): void
		{
			if (fadeTimer) {
				fadeTimer.stop();
				fadeTimer = null;
			}
			
			if (musicChannel) {
				musicPosition = musicChannel.position;
				
				if (music) {
					musicPosition %= music.length;
				}
				
				musicChannel.stop();
				musicChannel = null;
			}
			
			if (rainChannel) {
				rainChannel.stop();
				rainChannel = null;
			}
		}
		
		public static function switchMusic (): void
		{
			if (musicChannel) {
				musicChannel.stop();
			}
			
			music = gentleMusic;
			
			if (! mute)
			{
				// MP3 encoding annoyingly puts empty space at the beginning: 55ms in this case
				musicChannel = music.play(55, int.MAX_VALUE);
				musicPosition = 0;
			}
		}
		
		public static function startGame (): void
		{
			stopMusic();
			
			rainVolume = 0;
			
			music = actionMusic;
			
			musicPosition = 0;
		}
		
		public static function fadeOut (): void
		{
			if (music == actionMusic) {
				stopMusic();
				
				music = null;
				
				return;
			}
			
			music = null;
			
			const duration: int = 4000;
			const inverseFPS: int = 50;
			const count: int = int.MAX_VALUE;//duration / inverseFPS;
			
			fadeTimer = new Timer(inverseFPS, count);
			
			fadeTimer.addEventListener(TimerEvent.TIMER, runMe);
			fadeTimer.start();
			
			var volume: Number = 1;
			
			function runMe():void{
			    //volume -= 1.0 / (duration / inverseFPS - 1);
			    
			    volume *= 0.97;

				if (! (FP.world is Level)) {
					rainVolume *= 0.95;
				}

			    if (volume <= 0.01 && rainVolume <= 0.01) {
			    	stopMusic();
			    } else {
			    	var transform: SoundTransform = musicChannel.soundTransform;
					
					transform.volume = volume;
					
					musicChannel.soundTransform = transform;
			    }
			}
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
		
		public static function playRain () : void
		{
			if (! mute && music == gentleMusic)
			{
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

