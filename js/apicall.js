// Contents of script.js
fetch('https://1q0ypgeji4.execute-api.us-east-1.amazonaws.com/v1', {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json',
  }
})
.then(response => response.json())
.then(data => {
    console.log("HIIII")
  document.getElementById('visitCount').textContent = data.visits;
})
.catch((error) => {
  console.error('Error:----', error);
  document.getElementById('visitCount').textContent = 'Error: ' + error;
});
