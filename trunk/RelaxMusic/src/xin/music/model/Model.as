package xin.music.model
{
	import mx.collections.ArrayCollection;

	import xin.music.control.Control;
	import xin.music.view.images.Images;

	public class Model
	{
		public var control:Control;

		[Bindable]
		public var images:Images;

		[Bindable]
		public var musicList:ArrayCollection;

		[Bindable]
		public var status:String = "";

		public function Model()
		{
			images = new Images();
			musicList = new ArrayCollection();
		}
	}
}
