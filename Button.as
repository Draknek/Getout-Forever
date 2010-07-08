package
{
	import flash.display.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.events.MouseEvent;
	
	import net.flashpunk.FP;
	
	public class Button extends Sprite
	{
		[Embed(source="button.png")]
		public static var buttonGfx : Class;
		
		[Embed(source="button-hover.png")]
		public static var buttonHoverGfx : Class;
		
		public var textField: MyTextField;
		
		public var bitmap1: Bitmap;
		public var bitmap2: Bitmap;
		
		public function Button (_text: String, _y: Number)
		{
			var bg: BitmapData = FP.getBitmap(buttonGfx).clone();
			
			do {
				var r: Number = Math.random();
				var g: Number = Math.random();
				var b: Number = Math.random();
			}
			while (r + g + b < 1);
			
			bg.colorTransform(bg.rect, new ColorTransform(r, g, b));
			
			bitmap1 = new Bitmap(bg);
			
			bg = FP.getBitmap(buttonHoverGfx).clone();
			bg.colorTransform(bg.rect, new ColorTransform(r, g, b));
			bitmap2 = new Bitmap(bg);
			
			bitmap2.visible = false;
			
			addChild(bitmap1);
			addChild(bitmap2);
			
			x = 320 - bg.width * 0.5;
			y = _y;
			
			textField = new MyTextField(0, 0, _text, "center", 32);
			
			textField.textColor = 0x000000;
			
			textField.x = (bg.width-textField.width) * 0.5;
			textField.y = (bg.height-textField.height) * 0.5;
			
			/*var _height: Number = textField.height + 10;
			
			_width = Math.max(_width, textField.width + 20);
			
			textField.x = _width / 2 - textField.width / 2;*/
			
			addChild(textField);
			
			buttonMode = true;
			mouseChildren = false;
			
			addEventListener(MouseEvent.ROLL_OVER, function (param: * = 0) : void {bitmap2.visible = true; bitmap1.visible = false;});
			addEventListener(MouseEvent.ROLL_OUT, function (param: * = 0) : void {bitmap1.visible = true; bitmap2.visible = false;});
		}
		
	}
}

