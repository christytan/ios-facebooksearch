<?php 
	

	if(isset($_GET['key'])) {


		$key = $_GET['key'];
		$tab = $_GET['tab'];
		$access_token = "EAABpj6aOxawBABppDv5Y9jSju2o8Sup9hgptAIISjtpuU6DJyWXN1YPbXRdNIH9MD43wjRZCtK2NeGuiKIwAvTmnsNfTEU2sXnWvGiZBMd0IOh67TiYSSlf9LD8R4maXq0y9wdsg8poCDEwlr35pZByO00NfYydkyoHmCUGzzH28Ra9dL4aRDcZCu0U0W7AZD";


		if($tab != 'place') {

			if (preg_match("/\\s/", $key)){
				$key = str_replace(' ', '%20', $key);
			}

			$content=file_get_contents("https://graph.facebook.com/v2.8/search?q=$key&type=$tab&fields=id,name,picture.width(700).height(700)&limit=10&access_token=$access_token");
			echo $content;
		}
		else {
			$lat = $_GET['lat'];
			$lng = $_GET['lng'];
			$contentplace=file_get_contents("https://graph.facebook.com/v2.8/search?q=$key&type=$tab&fields=id,name,picture.width(700).height(700)&limit=10&center=$lat,$lng&access_token=$access_token");
			echo $contentplace;
		}


	}

	if(isset($_GET['id'])) {
		$ida = $_GET['id'];
		$result = file_get_contents("https://graph.facebook.com/v2.8/$ida?fields=name,picture.width(700).height(700),albums.limit(5){name,photos.limit(2){name,%20picture}},posts.limit(5){created_time,message}&access_token=$access_token");
		echo $result;

	}

	 

	
	
?>