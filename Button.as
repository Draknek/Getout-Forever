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
		
		public var textField: MyTextField;
		
		public function Button (_text: String, _y: Number)
		{
			var bg: BitmapData = FP.getBitmap(buttonGfx).clone();
			
			bg.colorTransform(bg.rect, new ColorTransform(1, 0, 0));
			
			addChild(new Bitmap(bg));
			
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
			
			//addEventListener(MouseEvent.ROLL_OVER, function (param: * = 0) : void {textField.textColor = 0xFFFFFF});
			//addEventListener(MouseEvent.ROLL_OUT, function (param: * = 0) : void {textField.textColor = 0x000000});
		}
		
	}
}

