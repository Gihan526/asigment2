// Run only against a demo project with the Firestore emulator; no extra npm packages.
const assert = require('node:assert/strict');
const host = process.env.FIRESTORE_EMULATOR_HOST;
const project = process.env.GCLOUD_PROJECT;
assert(host && project?.startsWith('demo-'), 'Use firebase emulators:exec --project demo-foundly.');
const root = `http://${host}/v1/projects/${project}/databases/(default)/documents`;
let passed = 0;
const encode = value => Buffer.from(JSON.stringify(value)).toString('base64url');
function token(uid) {
  const now = Math.floor(Date.now()/1000);
  return `${encode({alg:'none',typ:'JWT'})}.${encode({
    aud:project,iss:`https://securetoken.google.com/${project}`,sub:uid,user_id:uid,
    email:`${uid}@campus.edu`,email_verified:true,iat:now,exp:now+3600,
    firebase:{sign_in_provider:'password',identities:{email:[`${uid}@campus.edu`]}}
  })}.`;
}
function fields(data) {
  return Object.fromEntries(Object.entries(data).map(([k,v]) => [k,
    v instanceof Date ? {timestampValue:v.toISOString()} :
    typeof v === 'boolean' ? {booleanValue:v} :
    typeof v === 'number' ? {integerValue:String(v)} : {stringValue:v}
  ]));
}
async function request(label, uid, suffix, method='GET', body, allowed=true) {
  const response = await fetch(root+suffix, {method, headers:{
    'Content-Type':'application/json', ...(uid ? {Authorization:`Bearer ${token(uid)}`} : {})
  }, ...(body ? {body:JSON.stringify(body)} : {})});
  const result = await response.json();
  assert.equal(response.status, allowed ? 200 : 403, `${label}: ${JSON.stringify(result)}`);
  passed++;
  console.log(`PASS ${label}`);
  return result;
}
function write(path, data, options={}) {
  return {update:{name:`projects/${project}/databases/(default)/documents/${path}`,fields:fields(data)}, ...options};
}
function create(path,data) {
  return {writes:[write(path,data,{currentDocument:{exists:false},
    updateTransforms:[{fieldPath:'createdAt',setToServerValue:'REQUEST_TIME'}]})]};
}
function patch(path,data, mask=Object.keys(data)) {
  return {writes:[write(path,data,{currentDocument:{exists:true},updateMask:{fieldPaths:mask}})]};
}
async function denyPatch(label,path,data,mask) {
  return request(label,'alice',':commit','POST',patch(path,data,mask),false);
}
(async()=>{
  await request('public item list denied',null,'/items','GET',undefined,false);
  await request('profile creation allowed','alice',':commit','POST',create('users/alice',{uid:'alice',name:'Alice',email:'alice@campus.edu'}));
  await request('owner profile read allowed','alice','/users/alice');
  await request('other student profile read denied','bob','/users/alice','GET',undefined,false);
  await request('public profile read denied',null,'/users/alice','GET',undefined,false);
  await request('profile list denied','bob','/users','GET',undefined,false);
  await request('profile update allowed','alice',':commit','POST',patch('users/alice',{name:'Alice Student'}));
  await request('other student profile update denied','bob',':commit','POST',patch('users/alice',{name:'Hijack'}),false);
  await denyPatch('role injection denied','users/alice',{isAdmin:true});
  await denyPatch('profile ownership change denied','users/alice',{uid:'bob'});
  await denyPatch('profile date change denied','users/alice',{createdAt:new Date(0)});
  await denyPatch('profile required field deletion denied','users/alice',{},['name']);
  await denyPatch('profile oversized name denied','users/alice',{name:'x'.repeat(201)});
  await request('forged profile creation denied','alice',':commit','POST',create('users/bob',{uid:'bob',name:'Bob',email:'bob@campus.edu'}),false);
  const item = {id:'item1',title:'Backpack',location:'Library',description:'Blue',contactInfo:'Security desk',imageUrl:'https://example.com/photo.jpg',storagePath:'lost_items/item1_123.jpg',userId:'alice',userName:'Alice',userEmail:'alice@campus.edu',isClaimed:false};
  await request('item creation allowed','alice',':commit','POST',create('items/item1',item));
  await request('student item read allowed','bob','/items/item1');
  await request('newest-first feed query allowed','bob',':runQuery','POST',{structuredQuery:{from:[{collectionId:'items'}],orderBy:[{field:{fieldPath:'createdAt'},direction:'DESCENDING'}]}});
  await request('public item read denied',null,'/items/item1','GET',undefined,false);
  await request('non-owner item update denied','bob',':commit','POST',patch('items/item1',{title:'Hijack'}),false);
  await request('owner item edit allowed','alice',':commit','POST',patch('items/item1',{title:'Blue backpack'}));
  await request('owner claim allowed','alice',':commit','POST',patch('items/item1',{isClaimed:true}));
  await request('owner unclaim allowed','alice',':commit','POST',patch('items/item1',{isClaimed:false}));
  await denyPatch('item ownership change denied','items/item1',{userId:'bob'});
  await denyPatch('item ID change denied','items/item1',{id:'item2'});
  await denyPatch('item date change denied','items/item1',{createdAt:new Date(0)});
  await denyPatch('poster identity change denied','items/item1',{userEmail:'bob@campus.edu'});
  await denyPatch('invalid boolean denied','items/item1',{isClaimed:'true'});
  await denyPatch('required item field deletion denied','items/item1',{},['location']);
  await denyPatch('unknown item field denied','items/item1',{role:'admin'});
  await denyPatch('wrong image path denied','items/item1',{storagePath:'lost_items/item2_123.jpg'});
  await denyPatch('insecure image URL denied','items/item1',{imageUrl:'http://example.com/photo.jpg'});
  for (const [key,max] of Object.entries({title:200,location:200,description:5000,contactInfo:2000,imageUrl:2048,storagePath:300,userName:200,userEmail:320,userId:128,id:128})) {
    await denyPatch(`oversized ${key} denied`,'items/item1',{[key]:'x'.repeat(max+1)});
  }
  await request('forged item ownership denied','bob',':commit','POST',create('items/item2',{...item,id:'item2',storagePath:'lost_items/item2_123.jpg'}),false);
  await request('false creation date denied','alice',':commit','POST',{writes:[write('items/item3',{...item,id:'item3',storagePath:'lost_items/item3_123.jpg',createdAt:new Date(0)})]},false);
  await request('unmatched subcollection denied','alice','/users/alice/private/test','GET',undefined,false);
  await request('unmatched collection denied','alice','/test/test','GET',undefined,false);
  await request('non-owner item delete denied','bob','/items/item1','DELETE',undefined,false);
  await request('owner item delete allowed','alice',':commit','POST',{writes:[{delete:`projects/${project}/databases/(default)/documents/items/item1`}]});
  console.log(`${passed} Firestore rules checks passed.`);
})().catch(error=>{console.error(error.message);process.exitCode=1;});
