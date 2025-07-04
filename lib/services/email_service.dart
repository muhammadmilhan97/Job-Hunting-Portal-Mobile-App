import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _apiUrl =
      'https://job-hunting-portal-mobile-app.vercel.app/api/send-email';

  static Future<bool> sendJobApplicationEmail({
    required String to,
    required String subject,
    required String text,
    required String html,
  }) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'to': to,
        'subject': subject,
        'text': text,
        'html': html,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<bool> sendWelcomeEmail({
    required String to,
    required String userName,
    required String userType,
  }) async {
    String subject;
    String text;
    String html;

    if (userType == 'job_seeker') {
      subject =
          '🎉 Welcome to JobHunt by Muhammad Milhan - Your Career Journey Starts Here!';
      text = '''
Hi $userName,

Congratulations and welcome aboard!

You've just taken the first step toward unlocking incredible job opportunities with JobHunt by Muhammad Milhan - a platform designed to make your career dreams a reality.

Here's what you can start doing right now:
🔹 Build and polish your job seeker profile
🔹 Browse personalized job listings across industries
🔹 Apply to jobs directly and track your applications
🔹 Stay updated with real-time job alerts

We're here to empower you at every step of your job hunt. Your ambition deserves the right opportunity—and we're committed to helping you find it.

Need help or have questions? Reach us anytime at jobhuntapplication@gmail.com.

Wishing you a journey full of success and growth,
Muhammad Milhan
Founder – JobHunt
''';
      html = '''
<p>Hi $userName,</p>
<p>Congratulations and welcome aboard!</p>
<p>You've just taken the first step toward unlocking incredible job opportunities with <b>JobHunt by Muhammad Milhan</b> - a platform designed to make your career dreams a reality.</p>
<p><b>Here's what you can start doing right now:</b></p>
<ul>
  <li>🔹 Build and polish your job seeker profile</li>
  <li>🔹 Browse personalized job listings across industries</li>
  <li>🔹 Apply to jobs directly and track your applications</li>
  <li>🔹 Stay updated with real-time job alerts</li>
</ul>
<p>We're here to empower you at every step of your job hunt. Your ambition deserves the right opportunity—and we're committed to helping you find it.</p>
<p><b>👉 <a href="https://job-hunting-portal-mobile-app.vercel.app/">Go to Your Dashboard</a></b></p>
<p>Need help or have questions? Reach us anytime at <b>jobhuntapplication@gmail.com</b>.</p>
<p>Wishing you a journey full of success and growth,<br>
<b>Muhammad Milhan</b><br>
Founder – JobHunt</p>
''';
    } else {
      subject =
          '🚀 Welcome to JobHunt by Muhammad Milhan - Find Top Talent Faster!';
      text = '''
Hi $userName,

Welcome to JobHunt by Muhammad Milhan - your trusted partner in building the perfect team!

We're thrilled to have you onboard. With your employer account, you can now:
🔹 Post detailed job listings effortlessly
🔹 Access a growing network of talented professionals
🔹 Review and manage applications in a smart dashboard
🔹 Hire faster with confidence and ease

Our mission is simple: connect you with the right talent at the right time.

If you have any questions or need guidance, we're always here to help at jobhuntapplication@gmail.com.

Let's build something great together,
Muhammad Milhan
Founder – JobHunt
''';
      html = '''
<p>Hi $userName,</p>
<p>Welcome to <b>JobHunt by Muhammad Milhan</b> - your trusted partner in building the perfect team!</p>
<p>We're thrilled to have you onboard. With your employer account, you can now:</p>
<ul>
  <li>🔹 Post detailed job listings effortlessly</li>
  <li>🔹 Access a growing network of talented professionals</li>
  <li>🔹 Review and manage applications in a smart dashboard</li>
  <li>🔹 Hire faster with confidence and ease</li>
</ul>
<p>Our mission is simple: <b>connect you with the right talent at the right time</b>.</p>
<p><b>👉 <a href="https://job-hunting-portal-mobile-app.vercel.app/">Post Your First Job Now</a></b></p>
<p>If you have any questions or need guidance, we're always here to help at <b>jobhuntapplication@gmail.com</b>.</p>
<p>Let's build something great together,<br>
<b>Muhammad Milhan</b><br>
Founder – JobHunt</p>
''';
    }

    return await EmailService.sendJobApplicationEmail(
      to: to,
      subject: subject,
      text: text,
      html: html,
    );
  }

  static Future<bool> sendApplicationStatusUpdate({
    required String to,
    required String userName,
    required String jobTitle,
    required String companyName,
    required String status, // 'accepted', 'rejected', 'interview_scheduled'
    String? interviewDateTime,
    String? employerName,
    String? meetingLink,
  }) async {
    String subject = '';
    String text = '';
    String html = '';
    if (status == 'accepted') {
      subject = '🎉 You\'ve Been Accepted for the Role - $jobTitle';
      text = '''
Hi $userName,

Good news! Your application for the position of $jobTitle at $companyName has been accepted.

The employer is impressed with your profile and will be in touch with further steps. Keep an eye on your dashboard for updates.

Wishing you all the best on this exciting journey!

Warm regards,
JobHunt by Muhammad Milhan
jobhuntapplication@gmail.com
''';
      html = '''
<p>Hi $userName,</p>
<p>Good news! Your application for the position of <b>$jobTitle</b> at <b>$companyName</b> has been <b>accepted</b>.</p>
<p>The employer is impressed with your profile and will be in touch with further steps. Keep an eye on your dashboard for updates.</p>
<p>Wishing you all the best on this exciting journey!</p>
<p>Warm regards,<br><b>JobHunt by Muhammad Milhan</b><br>jobhuntapplication@gmail.com</p>
''';
    } else if (status == 'rejected') {
      subject = 'Application Update for $jobTitle - Status: Rejected';
      text = '''
Hi $userName,

Thank you for applying to $jobTitle at $companyName. We appreciate your interest and the time you took to apply.

After careful review, the employer has decided to move forward with other candidates for this role.

Don\'t be discouraged—many other great opportunities await you on JobHunt by Muhammad Milhan. Keep applying and stay persistent!

Sincerely,
JobHunt Team
jobhuntapplication@gmail.com
''';
      html = '''
<p>Hi $userName,</p>
<p>Thank you for applying to <b>$jobTitle</b> at <b>$companyName</b>. We appreciate your interest and the time you took to apply.</p>
<p>After careful review, the employer has decided to move forward with other candidates for this role.</p>
<p>Don\'t be discouraged—many other great opportunities await you on <b>JobHunt by Muhammad Milhan</b>. Keep applying and stay persistent!</p>
<p>Sincerely,<br><b>JobHunt Team</b><br>jobhuntapplication@gmail.com</p>
''';
    } else if (status == 'interview_scheduled') {
      subject = '📅 Interview Scheduled for $jobTitle - $interviewDateTime';
      text = '''
Hi $userName,

Great news! Your application for $jobTitle at $companyName has progressed to the next stage.

An interview has been scheduled with the employer.

📍 Interview Details:
- Employer: $employerName
- Date & Time: $interviewDateTime
- Meeting Link: $meetingLink

Please make sure to be available on time and prepare accordingly. Good luck – you've got this!

Best wishes,
JobHunt by Muhammad Milhan
jobhuntapplication@gmail.com
''';
      html = '''
<p>Hi $userName,</p>
<p>Great news! Your application for <b>$jobTitle</b> at <b>$companyName</b> has progressed to the next stage.</p>
<p>An interview has been scheduled with the employer.</p>
<ul>
  <li><b>Employer:</b> $employerName</li>
  <li><b>Date & Time:</b> $interviewDateTime</li>
  <li><b>Meeting Link:</b> <a href="$meetingLink">$meetingLink</a></li>
</ul>
<p>Please make sure to be available on time and prepare accordingly. Good luck – you've got this!</p>
<p>Best wishes,<br><b>JobHunt by Muhammad Milhan</b><br>jobhuntapplication@gmail.com</p>
''';
    }
    return await EmailService.sendJobApplicationEmail(
      to: to,
      subject: subject,
      text: text,
      html: html,
    );
  }

  static Future<bool> sendManualInterviewScheduled({
    required String to,
    required String userName,
    required String jobTitle,
    required String companyName,
    required String interviewDateTime,
    required String employerName,
    required String meetingLink,
  }) async {
    final subject =
        '🎤 Your Interview is Scheduled - $jobTitle at $companyName';
    final text = '''
Hi $userName,

You've been selected for an interview for the role of $jobTitle at $companyName.

Here are the interview details:

🗓 Date & Time: $interviewDateTime
👤 Employer: $employerName
🔗 Meeting Link: $meetingLink

Make sure to join on time and have a stable internet connection.

We wish you the best of luck!

Sincerely,
JobHunt by Muhammad Milhan
jobhuntapplication@gmail.com
''';
    final html = '''
<p>Hi $userName,</p>
<p>You've been selected for an interview for the role of <b>$jobTitle</b> at <b>$companyName</b>.</p>
<p>Here are the interview details:</p>
<ul>
  <li>🗓 <b>Date & Time:</b> $interviewDateTime</li>
  <li>👤 <b>Employer:</b> $employerName</li>
  <li>🔗 <b>Meeting Link:</b> <a href="$meetingLink">$meetingLink</a></li>
</ul>
<p>Make sure to join on time and have a stable internet connection.</p>
<p>We wish you the best of luck!</p>
<p>Sincerely,<br><b>JobHunt by Muhammad Milhan</b><br>jobhuntapplication@gmail.com</p>
''';
    return await EmailService.sendJobApplicationEmail(
      to: to,
      subject: subject,
      text: text,
      html: html,
    );
  }

  static Future<bool> sendCVUpdateConfirmation({
    required String to,
    required String userName,
  }) async {
    final subject = '✅ CV Updated Successfully on JobHunt';
    final text = '''
Hi $userName,

This is to confirm that your CV has been successfully updated in your profile on JobHunt by Muhammad Milhan.

A well-crafted and up-to-date CV boosts your chances of landing interviews—great job staying proactive!

Feel free to explore new job postings anytime.

Cheers,
JobHunt Team
jobhuntapplication@gmail.com
''';
    final html = '''
<p>Hi $userName,</p>
<p>This is to confirm that your CV has been successfully updated in your profile on <b>JobHunt by Muhammad Milhan</b>.</p>
<p>A well-crafted and up-to-date CV boosts your chances of landing interviews—great job staying proactive!</p>
<p>Feel free to explore new job postings anytime.</p>
<p>Cheers,<br><b>JobHunt Team</b><br>jobhuntapplication@gmail.com</p>
''';
    return await EmailService.sendJobApplicationEmail(
      to: to,
      subject: subject,
      text: text,
      html: html,
    );
  }

  static Future<bool> sendPasswordReset({
    required String to,
    required String userName,
    required String resetLink,
  }) async {
    final subject = '🔐 Password Reset Requested for Your JobHunt Account';
    final text = '''
Hi $userName,

We received a request to reset the password for your account on JobHunt by Muhammad Milhan.

To reset your password, click the link below:
$resetLink

If you did not request this, please ignore this email or contact our support team immediately.

Stay secure,
JobHunt Team
jobhuntapplication@gmail.com
''';
    final html = '''
<p>Hi $userName,</p>
<p>We received a request to reset the password for your account on <b>JobHunt by Muhammad Milhan</b>.</p>
<p>To reset your password, click the link below:<br>
<a href="$resetLink">$resetLink</a></p>
<p>If you did not request this, please ignore this email or contact our support team immediately.</p>
<p>Stay secure,<br><b>JobHunt Team</b><br>jobhuntapplication@gmail.com</p>
''';
    return await EmailService.sendJobApplicationEmail(
      to: to,
      subject: subject,
      text: text,
      html: html,
    );
  }

  static Future<bool> sendNewMatchingJob({
    required String to,
    required String userName,
    required String jobTitle,
    required String companyName,
    required String jobLink,
  }) async {
    final subject =
        '🌟 New Job That Matches Your Profile - $jobTitle at $companyName';
    final text = '''
Hi $userName,

A new job has just been posted that aligns with your skills and interests!

📌 Job Title: $jobTitle
🏢 Company: $companyName
🔗 View Job: $jobLink

Don't miss this opportunity—apply today and take one step closer to your career goals.

Best of luck!
JobHunt by Muhammad Milhan
jobhuntapplication@gmail.com
''';
    final html = '''
<p>Hi $userName,</p>
<p>A new job has just been posted that aligns with your skills and interests!</p>
<ul>
  <li>📌 <b>Job Title:</b> $jobTitle</li>
  <li>🏢 <b>Company:</b> $companyName</li>
  <li>🔗 <b>View Job:</b> <a href="$jobLink">$jobLink</a></li>
</ul>
<p>Don't miss this opportunity—apply today and take one step closer to your career goals.</p>
<p>Best of luck!<br><b>JobHunt by Muhammad Milhan</b><br>jobhuntapplication@gmail.com</p>
''';
    return await EmailService.sendJobApplicationEmail(
      to: to,
      subject: subject,
      text: text,
      html: html,
    );
  }
}
