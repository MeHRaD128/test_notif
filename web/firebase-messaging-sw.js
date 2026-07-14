importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDLdbc3S7Uplz-dVMNv1Iutm4Rei10WxAE",
  authDomain: "moshir-bb5ff.firebaseapp.com",
  projectId: "moshir-bb5ff",
  storageBucket: "moshir-bb5ff.firebasestorage.app",
  messagingSenderId: "848364028034",
  appId: "1:848364028034:web:a0596b73cfafc0a9b9749b"
});

const messaging = firebase.messaging();
