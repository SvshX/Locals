var functions = require('firebase-functions');
var mandrill = require('node-mandrill')('8lletQK_pNebgoImOJNcCA');


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

// Sends an email confirmation when a user changes his mailing list subscription.
exports.sendTipReportMail = functions.database.ref('/tips/{key}').onWrite(event => {
  const snapshot = event.data;
  const val = snapshot.val();
  const exists = snapshot.hasChild('isActive');
  var uid = event.auth.variable.uid;

  if (!exists || !snapshot.changed('isActive')) {
    return;
  }


  // The user just reported the tip - isActive == false
  if (!val.isActive) {

if (val.reportType === "") {
  return;
}

var optionalMessage = "No message added"
if (val.reportMessage !== "") {
  optionalMessage = val.reportMessage
}
    var repMessage = "Tip ID: " + snapshot.key + "\n\nCategory: " + val.category + "\n\nDescription: " + val.description + "\n\nAdded by (User ID): " + val.addedByUser + "\n\nUser name: " + val.userName + "\n\n\n\nReport type: " + val.reportType + "\n\nOptional report message: " + optionalMessage + "\n\nReported by: " + uid
   
   mandrill('/messages/send', {
    message: {
        to: [{email: 'team@yaknakapp.com', name: 'Yaknak'}],
        from_email: 'team@yaknakapp.com',
        subject: "TIP REPORTED",
        text: repMessage
    }
}, function(error, response)
{
    //uh oh, there was an error
    if (error) console.log( JSON.stringify(error) );

    //everything's good, lets see what mandrill said
    else console.log(response);
});
  }

});



exports.sendUserMail = functions.database.ref('/users/{uid}').onWrite(event => {
  const snapshot = event.data;
  const val = snapshot.val();
  const exists = snapshot.hasChild('isActive');


  if (val.totalTips === 1 && event.data.previous.val().totalTips < 1) {

var firstTipMessage = "FIRST TIP!\n\n\nUser name: " + val.name + "\n\nUser email: " + val.email
   
   mandrill('/messages/send', {
    message: {
        to: [{email: 'team@yaknakapp.com', name: 'Yaknak'}],
        from_email: 'team@yaknakapp.com',
        subject: val.email,
        text: firstTipMessage
    }
}, function(error, response)
{
    //uh oh, there was an error
    if (error) console.log( JSON.stringify(error) );

    //everything's good, lets see what mandrill said
    else console.log(response);
});


  }

  if (!exists || !snapshot.changed('isActive')) {
    return;
  }


  // The user just subscribed to our newsletter.
  if (!val.isActive) {

if (val.reportType === "") {
  return;
}

var userOptionalMessage = "No message added"
if (val.reportMessage !== "") {
  userOptionalMessage = val.reportMessage
}
    var userRepMessage = "User ID: " + snapshot.key + "\n\nUser name: " + val.name + "\n\n\n\nReport type: " + val.reportType + "\n\nOptional report message: " + userOptionalMessage
   
   mandrill('/messages/send', {
    message: {
        to: [{email: 'team@yaknakapp.com', name: 'Yaknak'}],
        from_email: 'team@yaknakapp.com',
        subject: "USER REPORTED",
        text: userRepMessage
    }
}, function(error, response)
{
    //uh oh, there was an error
    if (error) console.log( JSON.stringify(error) );

    //everything's good, lets see what mandrill said
    else console.log(response);
});
  }

});



exports.sendWelcomeMail = functions.auth.user().onCreate(event => {
  // [START eventAttributes]
  const user = event.data; // The Firebase user.

  const email = user.email; // The email of the user.
  const displayName = user.displayName; // The display name of the user.
  // [END eventAttributes]
/*
    //var welcomeMessage = "Hey ${displayName},\n\nwelcome to the Yaknak family. We really hope the app will make it easier for you to find great\nthings to do nearby.\n\n\nAcross the world, Yakkers are uploading awesome tips every day! Are you clear how to upload\none yourself? (just tap the chat icon in the bottom left of the app).\n\n\nThe whole team would love to know how you are finding your Yaknak experience. Drop me a\nline anytime to let me know how you are finding things, or if you just fancy a chat.\n\n\nHappy yakking,\n\n\nHugo\n\n\n(P.S. any chance you could share the love? Tweeting this would mean the world to us.)\n\n\n--\nCo-founder, Yaknak\nteam@yaknakapp.com"
   var welcomeMessage = "<p>Hey!</p><p>&nbsp;</p><p>Welcome to the Yaknak family. We really hope the app will make it easier for you to find great things to do nearby.</p><p>&nbsp;</p><p>Across the world, Yakkers are uploading awesome tips every day! Are you clear how to upload one yourself? (just tap the chat icon in the bottom right of the app).</p><p>&nbsp;</p><p>The whole team would love to know how you are finding your Yaknak experience. Drop me a line anytime to let me know how you are finding things, or if you just fancy a chat.</p><p>&nbsp;</p><p>Happy yakking,</p><p>&nbsp;</p><p>Hugo</p><p>&nbsp;</p><p>(P.S. any chance you could share the love?&nbsp;<a href='https://twitter.com/intent/tweet?text=I'm%20digging%20@Yaknakapp%20-%20The%20fastest%20way%20to%20find%20things%20to%20do%20nearby.%20Join%20me%20on%20it!%20yaknakapp.com'>Tweeting this</a>&nbsp;would mean the world to us.)</p><p>&nbsp;</p><p>--</p><p>Co-founder, Yaknak</p><p>team@yaknakapp.com</p>"

   mandrill('/messages/send', {
    message: {
        to: [{email: email, name: displayName}],
        from_email: 'team@yaknakapp.com',
        from_name: 'Hugo Winn',
        subject: "Quick hello",
        html: welcomeMessage
       // text: welcomeMessage
    }
}, function(error, response)
{
    //uh oh, there was an error
    if (error) console.log( JSON.stringify(error) );

    //everything's good, lets see what mandrill said
    else console.log(response);
});
*/

var newUserMessage = "NEW USER!\n\n\nUser ID: " + user.uid + "\n\nUser name: " + displayName + "\n\nEmail: " + email
     mandrill('/messages/send', {
    message: {
        to: [{email: 'team@yaknakapp.com', name: 'Yaknak'}],
        from_email: 'team@yaknakapp.com',
        subject: email,
        text: newUserMessage
       // text: welcomeMessage
    }
}, function(error, response)
{
    //uh oh, there was an error
    if (error) console.log( JSON.stringify(error) );

    //everything's good, lets see what mandrill said
    else console.log(response);
});

});



exports.sendNewTipMail = functions.database.ref('tips/{key}').onWrite(event => {

const snapshot = event.data;
const val = snapshot.val();

if (event.data.previous.exists()) {
    // Return here if tip already exists
    return;
  }

    var addedMessage = "Category: " + val.category + "\n\nDescription: " + val.description + "\n\nUser name: " + val.userName
   
   mandrill('/messages/send', {
    message: {
        to: [{email: 'team@yaknakapp.com', name: 'Yaknak'}],
        from_email: 'team@yaknakapp.com',
        subject: "TIP ADDED",
        text: addedMessage
    }
}, function(error, response)
{
    //uh oh, there was an error
    if (error) console.log( JSON.stringify(error) );

    //everything's good, lets see what mandrill said
    else console.log(response);
});

});
