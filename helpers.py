"""
Helper functions.

This is a set of helper function that migrating from project to project. Some functions is specific for Django Web 
Framework but most of them is pretty useful

Author: Alex Shanin
"""
import os
import re
import io
import base64
from uuid import UUID, uuid4
from PIL import Image
import string
import random
from datetime import datetime, timedelta

from django.conf import settings


##################################
#   FUNCTIONS
##################################
def get_random_string(length: int) -> str:
    """
    Random string generator.
    @:param length - number - length of string you want to get
    @:return random string
    """
    symbols = string.ascii_uppercase + string.ascii_lowercase + '1234567890'
    return ''.join(random.choice(symbols) for i in range(length))


def get_random_integer(length: int) -> int:
    """
    Generate random integer of given length. Not the range between 2 numbers,
    but length of a result number.
    :param length: integer of result number length
    :return: random interger
    """
    return random.randint(pow(10, length - 1), pow(10, length) - 1)


def get_random_datetime(m_year=1990, max_year=datetime.now().year):
    # generate a datetime in format yyyy-mm-dd hh:mm:ss.000000
    start = datetime(m_year, 1, 1, 00, 00, 00)
    years = max_year - m_year + 1
    end = start + timedelta(days=365 * years)
    return start + (end - start) * random.random()


def upload_location(instance, filename):
    """TODO: update annotation
    Create folder path of instance related object
    Arguments:
        - instance - object - instance of class that will be saved
        - filename - string - name of file that will be saved
    Return:
        string"""
    # ext = os.path.splitext(filename)[1]
    # fn = filename + '_' + get_random_string(16) + ext
    folder_name = str(instance.owner.id)
    return f"{folder_name}/{filename}"


def remove_instance_source_file(source_link):
    """TODO: update annotation
    Source file url in media library where stored all instance related uploaded information's.
    :param source_link: - instance source link that will be removed
    :return: None
    """
    global_file_path = f'{settings.MEDIA_ROOT}/{source_link}'
    if os.path.isfile(global_file_path):
        os.remove(global_file_path)
    # TODO: if user uploaded folder is empty - remove folder ( do not harvest empty folders on server! )


def is_base64_string(sb):
    """
    Check if given string or bite string is encoded in base64
    :param sb: string or bites
    :return: boolean
    """
    try:
        if isinstance(sb, str):
            # If there's any unicode here,
            # an exception will be thrown and the function will return false
            sb_bytes = bytes(sb, 'ascii')
        elif isinstance(sb, bytes):
            sb_bytes = sb
        else:
            raise ValueError("Argument must be string or bytes")
        return base64.b64encode(base64.b64decode(sb_bytes)) == sb_bytes
    except Exception:
        return False


def save_base64_image(image_data: str):
    """
    Convert base64 image string to actual image.
    :param image_data: base64 string image data
    :return: path of saved image
    """
    base64_data = re.sub('^data:image/.+;base64,', '', image_data)
    image = base64.b64decode(str(base64_data))
    file_name = f'/selfies/{str(uuid4())}.jpeg'
    image_path = settings.MEDIA_ROOT + file_name
    img = Image.open(io.BytesIO(image))
    img.save(image_path, 'jpeg')
    return image_path


def remove_screenshot_file(instance):
    """
    Remove selfie file from ConfirmInformation
    :param instance - object - instance that will be removed
    """
    file_name = instance.screenShot.split("/")[-1]
    file_path = os.path.join(settings.MEDIA_ROOT, f"/selfies/{file_name}")
    if os.path.exists(file_path):
        os.remove(file_path)
