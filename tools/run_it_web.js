// Runs the integration test web bundle in headless Chrome and streams console output.
const {chromium}=require('playwright-core');
const port=process.argv[2]||'8111';
(async()=>{
 const b=await chromium.launch({executablePath:'/usr/bin/google-chrome',args:['--no-sandbox']});
 const ctx=await b.newContext({viewport:{width:390,height:844},deviceScaleFactor:1});
 const p=await ctx.newPage();
 p.on('console',m=>console.log('[console]',m.text().slice(0,400)));
 p.on('pageerror',e=>console.log('[pageerror]',e.message));
 await p.goto('http://localhost:'+port+'/');
 const t0=Date.now();
 while(Date.now()-t0<600000){
   const r=await p.evaluate(()=>window.$flutterDriverResult||null).catch(()=>null);
   if(r){console.log('RESULT',r);break;}
   try{await p.waitForTimeout(3000);}catch(e){console.log('page closed by test harness');break;}
   if(((Date.now()-t0)/1000|0)%30<3) await p.screenshot({path:'/tmp/it_progress.png'}).catch(()=>{});
 }
 await p.screenshot({path:'/tmp/it_final.png'}).catch(()=>{});
 await b.close().catch(()=>{});
})();
