const {chromium}=require('playwright-core');
(async()=>{
 const b=await chromium.launch({executablePath:'/usr/bin/google-chrome',args:['--no-sandbox']});
 const p=await b.newPage({viewport:{width:2300,height:1200},deviceScaleFactor:2});
 await p.goto('file:///workspace/commute-app/mockups/mockups.html');
 await p.evaluate(()=>document.fonts.ready);await p.waitForTimeout(500);
 const ids=['tomorrow','route','add','places','settings'];
 for(const [i,id] of ids.entries()){await (await p.$('#'+id+' .phone')).screenshot({path:`/workspace/commute-app/mockups/0${i+1}_${id}.png`});}
 await p.screenshot({path:'/workspace/commute-app/mockups/00_overview.png',fullPage:true});
 await b.close();
})();
