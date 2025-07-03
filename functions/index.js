const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();
sgMail.setApiKey(functions.config().sendgrid.key);

exports.sendJobApplicationEmail = functions.firestore
  .document('applications/{applicationId}')
  .onCreate(async (snap, context) => {
    const application = snap.data();

    // Get job details (assuming you store jobId in application)
    const jobSnap = await admin.firestore().collection('jobs').doc(application.jobId).get();
    const job = jobSnap.data();

    // Get user details
    const userSnap = await admin.firestore().collection('users').doc(application.userId).get();
    const user = userSnap.data();

    // Compose email
    const msg = {
      to: user.email,
      from: 'your_verified_sender@example.com', // Must be a verified sender in SendGrid
      subject: `Application Received: ${job.title}`,
      text: `Hi ${user.name},\n\nYour application for "${job.title}" at ${job.company} has been received.\n\nThank you for applying!\n\nJob Details:\n${job.description}`,
      html: `<p>Hi ${user.name},</p>
             <p>Your application for <strong>${job.title}</strong> at <strong>${job.company}</strong> has been received.</p>
             <p>Thank you for applying!</p>
             <h4>Job Details:</h4>
             <p>${job.description}</p>`
    };

    try {
      await sgMail.send(msg);
      console.log('Email sent to', user.email);
    } catch (error) {
      console.error('SendGrid error:', error);
    }
  }); 