from pyyoutube import Api
from pytube import YouTube
  
def download_videos(url):
#     api = Api(api_key='<youtube api key>')
#     video = api.get_video_by_id(video_id=url.replace('https://www.youtube.com/watch?v=', ''), return_json=True)
    yt_obj = YouTube(url)
    filters = yt_obj.streams.filter(progressive=True, file_extension='mp4')
    filters.get_highest_resolution().download()
  
if __name__ == "__main__":
    url = input("Please enter the video link: ")
    download_videos(url)
