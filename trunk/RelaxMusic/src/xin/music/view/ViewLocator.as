package xin.music.view
{
	import flash.utils.Dictionary;

	public class ViewLocator
	{
		private static var viewLocator:ViewLocator;

		public var viewHelpers:Dictionary;

		public static function getInstance():ViewLocator
		{
			if(viewLocator == null)
				viewLocator = new ViewLocator();

			return viewLocator;
		}

		public function ViewLocator()
		{
			if(ViewLocator.viewLocator != null)
			{
				throw new Error("错误");
			}

			viewHelpers = new Dictionary();
		}

		public function register(viewName:String, viewHelper:ViewHelper):void
		{
			if(registrationExistsFor(viewName))
			{
				return;
			}

			viewHelpers[viewName] = viewHelper;
		}

		public function unregister(viewName:String):void
		{
			if(!registrationExistsFor(viewName))
			{
				return;
			}

			delete viewHelpers[viewName];
		}

		public function getViewHelper(viewName:String):ViewHelper
		{
			if(!registrationExistsFor(viewName))
			{
				return null;
			}

			return viewHelpers[viewName];
		}

		public function registrationExistsFor(viewName:String):Boolean
		{
			return viewHelpers[viewName] != undefined;
		}
	}
}
