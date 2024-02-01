// In a Cypress test file, like cypress/integration/test_lambda_function_spec.js

describe('Lambda Function Test', () => {
  it('increments the visit counter', () => {
    const url = 'https://qlvs90sd39.execute-api.us-east-1.amazonaws.com/Beta/';

    // First PUT request
    cy.request('PUT', url).then((response1) => {
      expect(response1.status).to.eq(200);
      const visits1 = response1.body.visits;

      // Second PUT request
      cy.request('PUT', url).then((response2) => {
        expect(response2.status).to.eq(200);
        const visits2 = response2.body.visits;

        // Assert that visits have incremented
        expect(visits2).to.be.greaterThan(visits1);
      });
    });

    

  });
});
