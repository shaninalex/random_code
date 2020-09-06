import axios from 'axios'
import { API_ROOT, credentials } from '../config';

uploadMultipleFiles = e => {
  let fileObj = e.target.files;
  let promises = [];
  let responses = [];
  for (let i = 0; i < fileObj.length; i++) {
    let formData = new FormData();
    formData.append('image', e.target.files[i]);
    
    // Save all axios in array
    promises.push(
      axios.post(`${API_ROOT}/api/v1/settings/file/`, formData, credentials())
      // Save all responses in array
      .then(response => responses.push(response))
    );
  }
  
  // And then run them all and read all responses saved in array.
  // Read manuals! https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all
  Promise.all(promises).then(() => console.log(responses));
};
