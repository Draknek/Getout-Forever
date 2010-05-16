package
{
	import flash.display.*;
	import flash.text.*;
	
	public class NumberTextField extends MyTextField
	{
		private var prefix: String;
		private var m_value: int;
		
		public function NumberTextField (_x: Number, _y: Number, _prefix: String, _autoSize: String = TextFieldAutoSize.CENTER, textSize: Number = 16)
		{
			super(_x, _y, _prefix, _autoSize, textSize);
			
			prefix = _prefix;
			
			value = 0;
		}
		
		public function set value(_value: int): void
		{
			m_value = _value;
			text = prefix + String(m_value);
		}
		
		public function get value(): int
		{
			return m_value;
		}
		
	}
}

