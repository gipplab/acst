const ipfsHttpClient = require('ipfs-http-client');
const express = require('express');
const bodyParser = require('body-parser');
const fileUpload = require('express-fileupload');
const fs = require('fs');
const path = require('path');

const app = express();
const ipfs = new ipfsHttpClient({ host: 'localhost', port: '5001', protocol: 'http'});

app.set('view engine', 'ejs');
app.use(bodyParser.urlencoded({extended: true}));
app.use(fileUpload());

app.get('/', (req, res) => {
    res.render('home');
});

app.post('/upload', (req, res) => {
    const file = req.files.file;
    const fileName = req.files.file.name;
    const filePath = path.join(__dirname, 'upload/files/') + file.name;

    file.mv(filePath, async (err) =>{
        
        if(err){
            console.log(err);
            console.log('error: failed to get the file');
            return res.status(500).send(err);
        }

        const hOfFile = await addFile(fileName, filePath);

        fs.unlink(filePath, (err) => {
            if(err) console.log(err);
        });

        res.render('upload', {fileName, hOfFile});

    });

});

const addFile = async (fileName, filePath) => {
    const file = fs.readFileSync(filePath);
    const fileAdded = await ipfs.add({path: fileName, content: file});
    //var cid = fileAdded.cid.substring(4, fileAdded.cid.length-2);
    //console.log("M01");
    //console.log(fileAdded.cid.toString());
    var cid = fileAdded.cid.toString();
    console.log("Added CID:");
    console.log(cid);
    
    return cid;
};

app.listen(3000, () => {
    console.log('Server list. on 3000');
});
