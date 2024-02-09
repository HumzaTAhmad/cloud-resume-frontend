// Contents of script.js
fetch('https://tpj89dndw6.execute-api.us-east-1.amazonaws.com/v1', {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json',
  }
})
.then(response => response.json())
.then(data => {
  document.getElementById('visitCount').textContent = data.visits;
})
.catch((error) => {
  console.error('Error:----', error);
  document.getElementById('visitCount').textContent = 'Error: ' + error;
});
