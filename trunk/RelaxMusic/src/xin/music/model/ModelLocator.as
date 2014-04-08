package xin.music.model
{

	[Bindable]
	public class ModelLocator
	{
		private static var instance:ModelLocator;

		public var model:Model;

		public function ModelLocator()
		{
			if(instance != null)
			{
				throw new (Error("错误！"));
			}

			initialize();
		}

		/**
		 *
		 * @return ModelLocator
		 */
		public static function getInstance():ModelLocator
		{
			if(instance == null)
			{
				instance = new ModelLocator();
			}

			return instance;
		}

		/**
		 *
		 */
		private function initialize():void
		{
			model = new Model();
		}
	}
}
