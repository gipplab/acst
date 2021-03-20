// WEBAPP FOR IPFS FILEUPLOAD
// It uses  ipfs-http-client to add files to IPFS
//          express as webframework
//          express-fileupload for the upload from client to server
//          

const ipfs_http_client = require('ipfs-http-client');
const express = require('express');
const body_parser = require('body-parser');
const file_upload = require('express-fileupload');
const fs = require('fs');
const path = require('path');


// Initializing express and creating an IPFS-client 
const app = express();
const ipfs = new ipfs_http_client({ host: 'localhost', port: '5001', protocol: 'http'});

// Set viewengine and enable fileupload
app.set('view engine', 'ejs');
app.use(body_parser.urlencoded({extended: true}));
app.use(file_upload());

// Set get
app.get('/', (req, res) => {
    res.render('home');
});

// Set post
app.post('/upload', (req, res) => {
    // We need some files at a specific place
    const file = req.files.file;
    const file_name = req.files.file.name;
    const file_path = path.join(__dirname, 'upload/files/') + file.name;

    file.mv(file_path, async (err) =>{
        
        if(err){
            console.log(err);
            console.log('error: failed to get the file');
            return res.status(500).send(err);
        }

        // with this function we add a file to IPFS
        const h_of_file = await add_file(file_name, file_path);

        fs.unlink(file_path, (err) => {
            if(err) console.log(err);
        });

        res.render('upload', {file_name, h_of_file});
        

    });

});


const add_file = async (file_name, file_path) => {
    // load the file
    const file = fs.readFileSync(file_path);
    // add the file to ipfs
    const file_added = await ipfs.add({path: file_name, content: file});

    // some debug
    //var cid = file_added.cid.substring(4, file_added.cid.length-2);
    //console.log("M01");
    //console.log(file_added.cid.toString());

    // print and return the cid
    var cid = file_added.cid.toString();
    console.log("Added CID:");
    console.log(cid);
    
    return cid;
};


// tell express to listen on port 3000
app.listen(3000, () => {
    console.log('Server list. on 3000');
});
