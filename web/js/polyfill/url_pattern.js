/* Credit: https://github.com/kenchris/urlpattern-polyfill */
var O=class{type=3;name="";prefix="";value="";suffix="";modifier=3;constructor(t,e,s,r,a,u){this.type=t,this.name=e,this.prefix=s,this.value=r,this.suffix=a,this.modifier=u}hasCustomName(){return this.name!==""&&typeof this.name!="number"}},Q=/[$_\p{ID_Start}]/u,Y=/[$_\u200C\u200D\p{ID_Continue}]/u,D=".*";function tt(t,e){return(e?/^[\x00-\xFF]*$/:/^[\x00-\x7F]*$/).test(t)}function M(t,e=!1){let s=[],r=0;for(;r<t.length;){let a=t[r],u=function(o){if(!e)throw new TypeError(o);s.push({type:"INVALID_CHAR",index:r,value:t[r++]})};if(a==="*"){s.push({type:"ASTERISK",index:r,value:t[r++]});continue}if(a==="+"||a==="?"){s.push({type:"OTHER_MODIFIER",index:r,value:t[r++]});continue}if(a==="\\"){s.push({type:"ESCAPED_CHAR",index:r++,value:t[r++]});continue}if(a==="{"){s.push({type:"OPEN",index:r,value:t[r++]});continue}if(a==="}"){s.push({type:"CLOSE",index:r,value:t[r++]});continue}if(a===":"){let o="",i=r+1;for(;i<t.length;){let h=t.substr(i,1);if(i===r+1&&Q.test(h)||i!==r+1&&Y.test(h)){o+=t[i++];continue}break}if(!o){u(`Missing parameter name at ${r}`);continue}s.push({type:"NAME",index:r,value:o}),r=i;continue}if(a==="("){let o=1,i="",h=r+1,n=!1;if(t[h]==="?"){u(`Pattern cannot start with "?" at ${h}`);continue}for(;h<t.length;){if(!tt(t[h],!1)){u(`Invalid character '${t[h]}' at ${h}.`),n=!0;break}if(t[h]==="\\"){i+=t[h++]+t[h++];continue}if(t[h]===")"){if(o--,o===0){h++;break}}else if(t[h]==="("&&(o++,t[h+1]!=="?")){u(`Capturing groups are not allowed at ${h}`),n=!0;break}i+=t[h++]}if(n)continue;if(o){u(`Unbalanced pattern at ${r}`);continue}if(!i){u(`Missing pattern at ${r}`);continue}s.push({type:"REGEX",index:r,value:i}),r=h;continue}s.push({type:"CHAR",index:r,value:t[r++]})}return s.push({type:"END",index:r,value:""}),s}function F(t,e={}){let s=M(t);e.delimiter??="/#?",e.prefixes??="./";let r=`[^${d(e.delimiter)}]+?`,a=[],u=0,o=0,i="",h=new Set,n=p=>{if(o<s.length&&s[o].type===p)return s[o++].value},f=()=>n("OTHER_MODIFIER")??n("ASTERISK"),w=p=>{let c=n(p);if(c!==void 0)return c;let{type:l,index:R}=s[o];throw new TypeError(`Unexpected ${l} at ${R}, expected ${p}`)},E=()=>{let p="",c;for(;c=n("CHAR")??n("ESCAPED_CHAR");)p+=c;return p},J=p=>p,P=e.encodePart||J,T="",U=p=>{T+=p},I=()=>{T.length&&(a.push(new O(3,"","",P(T),"",3)),T="")},_=(p,c,l,R,v)=>{let g=3;switch(v){case"?":g=1;break;case"*":g=0;break;case"+":g=2;break}if(!c&&!l&&g===3){U(p);return}if(I(),!c&&!l){if(!p)return;a.push(new O(3,"","",P(p),"",g));return}let m;l?l==="*"?m=D:m=l:m=r;let C=2;m===r?(C=1,m=""):m===D&&(C=0,m="");let b;if(c?b=c:l&&(b=u++),h.has(b))throw new TypeError(`Duplicate name '${b}'.`);h.add(b),a.push(new O(C,b,P(p),m,P(R),g))};for(;o<s.length;){let p=n("CHAR"),c=n("NAME"),l=n("REGEX");if(!c&&!l&&(l=n("ASTERISK")),c||l){let v=p??"";e.prefixes.indexOf(v)===-1&&(U(v),v=""),I();let g=f();_(v,c,l,"",g);continue}let R=p??n("ESCAPED_CHAR");if(R){U(R);continue}if(n("OPEN")){let v=E(),g=n("NAME"),m=n("REGEX");!g&&!m&&(m=n("ASTERISK"));let C=E();w("CLOSE");let b=f();_(v,g,m,C,b);continue}I(),w("END")}return a}function d(t){return t.replace(/([.+*?^${}()[\]|/\\])/g,"\\$1")}function j(t){return t&&t.ignoreCase?"ui":"u"}function et(t,e,s){return W(F(t,s),e,s)}function k(t){switch(t){case 0:return"*";case 1:return"?";case 2:return"+";case 3:return""}}function W(t,e,s={}){s.delimiter??="/#?",s.prefixes??="./",s.sensitive??=!1,s.strict??=!1,s.end??=!0,s.start??=!0,s.endsWith="";let r=s.start?"^":"";for(let i of t){if(i.type===3){i.modifier===3?r+=d(i.value):r+=`(?:${d(i.value)})${k(i.modifier)}`;continue}e&&e.push(i.name);let h=`[^${d(s.delimiter)}]+?`,n=i.value;if(i.type===1?n=h:i.type===0&&(n=D),!i.prefix.length&&!i.suffix.length){i.modifier===3||i.modifier===1?r+=`(${n})${k(i.modifier)}`:r+=`((?:${n})${k(i.modifier)})`;continue}if(i.modifier===3||i.modifier===1){r+=`(?:${d(i.prefix)}(${n})${d(i.suffix)})`,r+=k(i.modifier);continue}r+=`(?:${d(i.prefix)}`,r+=`((?:${n})(?:`,r+=d(i.suffix),r+=d(i.prefix),r+=`(?:${n}))*)${d(i.suffix)})`,i.modifier===0&&(r+="?")}let a=`[${d(s.endsWith)}]|$`,u=`[${d(s.delimiter)}]`;if(s.end)return s.strict||(r+=`${u}?`),s.endsWith.length?r+=`(?=${a})`:r+="$",new RegExp(r,j(s));s.strict||(r+=`(?:${u}(?=${a}))?`);let o=!1;if(t.length){let i=t[t.length-1];i.type===3&&i.modifier===3&&(o=s.delimiter.indexOf(i)>-1)}return o||(r+=`(?=${u}|${a})`),new RegExp(r,j(s))}var $={delimiter:"",prefixes:"",sensitive:!0,strict:!0},st={delimiter:".",prefixes:"",sensitive:!0,strict:!0},it={delimiter:"/",prefixes:"/",sensitive:!0,strict:!0};function rt(t,e){return t.length?t[0]==="/"?!0:!e||t.length<2?!1:(t[0]=="\\"||t[0]=="{")&&t[1]=="/":!1}function G(t,e){return t.startsWith(e)?t.substring(e.length,t.length):t}function nt(t,e){return t.endsWith(e)?t.substr(0,t.length-e.length):t}function K(t){return!t||t.length<2?!1:t[0]==="["||(t[0]==="\\"||t[0]==="{")&&t[1]==="["}var X=["ftp","file","http","https","ws","wss"];function V(t){if(!t)return!0;for(let e of X)if(t.test(e))return!0;return!1}function ot(t,e){if(t=G(t,"#"),e||t==="")return t;let s=new URL("https://example.com");return s.hash=t,s.hash?s.hash.substring(1,s.hash.length):""}function ht(t,e){if(t=G(t,"?"),e||t==="")return t;let s=new URL("https://example.com");return s.search=t,s.search?s.search.substring(1,s.search.length):""}function at(t,e){return e||t===""?t:K(t)?q(t):Z(t)}function ut(t,e){if(e||t==="")return t;let s=new URL("https://example.com");return s.password=t,s.password}function pt(t,e){if(e||t==="")return t;let s=new URL("https://example.com");return s.username=t,s.username}function ct(t,e,s){if(s||t==="")return t;if(e&&!X.includes(e))return new URL(`${e}:${t}`).pathname;let r=t[0]=="/";return t=new URL(r?t:"/-"+t,"https://example.com").pathname,r||(t=t.substring(2,t.length)),t}function ft(t,e,s){return z(e)===t&&(t=""),s||t===""?t:B(t)}function lt(t,e){return t=nt(t,":"),e||t===""?t:N(t)}function z(t){switch(t){case"ws":case"http":return"80";case"wws":case"https":return"443";case"ftp":return"21";default:return""}}function N(t){if(t==="")return t;if(/^[-+.A-Za-z0-9]*$/.test(t))return t.toLowerCase();throw new TypeError(`Invalid protocol '${t}'.`)}function mt(t){if(t==="")return t;let e=new URL("https://example.com");return e.username=t,e.username}function dt(t){if(t==="")return t;let e=new URL("https://example.com");return e.password=t,e.password}function Z(t){if(t==="")return t;if(/[\t\n\r #%/:<>?@[\]^\\|]/g.test(t))throw new TypeError(`Invalid hostname '${t}'`);let e=new URL("https://example.com");return e.hostname=t,e.hostname}function q(t){if(t==="")return t;if(/[^0-9a-fA-F[\]:]/g.test(t))throw new TypeError(`Invalid IPv6 hostname '${t}'`);return t.toLowerCase()}function B(t){if(t===""||/^[0-9]*$/.test(t)&&parseInt(t)<=65535)return t;throw new TypeError(`Invalid port '${t}'.`)}function gt(t){if(t==="")return t;let e=new URL("https://example.com");return e.pathname=t[0]!=="/"?"/-"+t:t,t[0]!=="/"?e.pathname.substring(2,e.pathname.length):e.pathname}function wt(t){return t===""?t:new URL(`data:${t}`).pathname}function yt(t){if(t==="")return t;let e=new URL("https://example.com");return e.search=t,e.search.substring(1,e.search.length)}function vt(t){if(t==="")return t;let e=new URL("https://example.com");return e.hash=t,e.hash.substring(1,e.hash.length)}var bt=class{#n;#i=[];#e={};#t=0;#r=1;#u=0;#h=0;#l=0;#m=0;#d=!1;constructor(t){this.#n=t}get result(){return this.#e}parse(){for(this.#i=M(this.#n,!0);this.#t<this.#i.length;this.#t+=this.#r){if(this.#r=1,this.#i[this.#t].type==="END"){if(this.#h===0){this.#v(),this.#p()?this.#s(9,1):this.#c()?this.#s(8,1):this.#s(7,0);continue}else if(this.#h===2){this.#f(5);continue}this.#s(10,0);break}if(this.#l>0)if(this.#C())this.#l-=1;else continue;if(this.#k()){this.#l+=1;continue}switch(this.#h){case 0:this.#b()&&this.#f(1);break;case 1:if(this.#b()){this.#O();let t=7,e=1;this.#$()?(t=2,e=3):this.#d&&(t=2),this.#s(t,e)}break;case 2:this.#w()?this.#f(3):(this.#y()||this.#c()||this.#p())&&this.#f(5);break;case 3:this.#E()?this.#s(4,1):this.#w()&&this.#s(5,1);break;case 4:this.#w()&&this.#s(5,1);break;case 5:this.#L()?this.#m+=1:this.#A()&&(this.#m-=1),this.#R()&&!this.#m?this.#s(6,1):this.#y()?this.#s(7,0):this.#c()?this.#s(8,1):this.#p()&&this.#s(9,1);break;case 6:this.#y()?this.#s(7,0):this.#c()?this.#s(8,1):this.#p()&&this.#s(9,1);break;case 7:this.#c()?this.#s(8,1):this.#p()&&this.#s(9,1);break;case 8:this.#p()&&this.#s(9,1);break;case 9:break;case 10:break}}this.#e.hostname!==void 0&&this.#e.port===void 0&&(this.#e.port="")}#s(t,e){switch(this.#h){case 0:break;case 1:this.#e.protocol=this.#a();break;case 2:break;case 3:this.#e.username=this.#a();break;case 4:this.#e.password=this.#a();break;case 5:this.#e.hostname=this.#a();break;case 6:this.#e.port=this.#a();break;case 7:this.#e.pathname=this.#a();break;case 8:this.#e.search=this.#a();break;case 9:this.#e.hash=this.#a();break;case 10:break}this.#h!==0&&t!==10&&([1,2,3,4].includes(this.#h)&&[6,7,8,9].includes(t)&&(this.#e.hostname??=""),[1,2,3,4,5,6].includes(this.#h)&&[8,9].includes(t)&&(this.#e.pathname??=this.#d?"/":""),[1,2,3,4,5,6,7].includes(this.#h)&&t===9&&(this.#e.search??="")),this.#x(t,e)}#x(t,e){this.#h=t,this.#u=this.#t+e,this.#t+=e,this.#r=0}#v(){this.#t=this.#u,this.#r=0}#f(t){this.#v(),this.#h=t}#g(t){return t<0&&(t=this.#i.length-t),t<this.#i.length?this.#i[t]:this.#i[this.#i.length-1]}#o(t,e){let s=this.#g(t);return s.value===e&&(s.type==="CHAR"||s.type==="ESCAPED_CHAR"||s.type==="INVALID_CHAR")}#b(){return this.#o(this.#t,":")}#$(){return this.#o(this.#t+1,"/")&&this.#o(this.#t+2,"/")}#w(){return this.#o(this.#t,"@")}#E(){return this.#o(this.#t,":")}#R(){return this.#o(this.#t,":")}#y(){return this.#o(this.#t,"/")}#c(){if(this.#o(this.#t,"?"))return!0;if(this.#i[this.#t].value!=="?")return!1;let t=this.#g(this.#t-1);return t.type!=="NAME"&&t.type!=="REGEX"&&t.type!=="CLOSE"&&t.type!=="ASTERISK"}#p(){return this.#o(this.#t,"#")}#k(){return this.#i[this.#t].type=="OPEN"}#C(){return this.#i[this.#t].type=="CLOSE"}#L(){return this.#o(this.#t,"[")}#A(){return this.#o(this.#t,"]")}#a(){let t=this.#i[this.#t],e=this.#g(this.#u).index;return this.#n.substring(e,t.index)}#O(){let t={};Object.assign(t,$),t.encodePart=N;let e=et(this.#a(),void 0,t);this.#d=V(e)}},S=["protocol","username","password","hostname","port","pathname","search","hash"],x="*";function H(t,e){if(typeof t!="string")throw new TypeError("parameter 1 is not of type 'string'.");let s=new URL(t,e);return{protocol:s.protocol.substring(0,s.protocol.length-1),username:s.username,password:s.password,hostname:s.hostname,port:s.port,pathname:s.pathname,search:s.search!==""?s.search.substring(1,s.search.length):void 0,hash:s.hash!==""?s.hash.substring(1,s.hash.length):void 0}}function y(t,e){return e?A(t):t}function L(t,e,s){let r;if(typeof e.baseURL=="string")try{r=new URL(e.baseURL),e.protocol===void 0&&(t.protocol=y(r.protocol.substring(0,r.protocol.length-1),s)),!s&&e.protocol===void 0&&e.hostname===void 0&&e.port===void 0&&e.username===void 0&&(t.username=y(r.username,s)),!s&&e.protocol===void 0&&e.hostname===void 0&&e.port===void 0&&e.username===void 0&&e.password===void 0&&(t.password=y(r.password,s)),e.protocol===void 0&&e.hostname===void 0&&(t.hostname=y(r.hostname,s)),e.protocol===void 0&&e.hostname===void 0&&e.port===void 0&&(t.port=y(r.port,s)),e.protocol===void 0&&e.hostname===void 0&&e.port===void 0&&e.pathname===void 0&&(t.pathname=y(r.pathname,s)),e.protocol===void 0&&e.hostname===void 0&&e.port===void 0&&e.pathname===void 0&&e.search===void 0&&(t.search=y(r.search.substring(1,r.search.length),s)),e.protocol===void 0&&e.hostname===void 0&&e.port===void 0&&e.pathname===void 0&&e.search===void 0&&e.hash===void 0&&(t.hash=y(r.hash.substring(1,r.hash.length),s))}catch{throw new TypeError(`invalid baseURL '${e.baseURL}'.`)}if(typeof e.protocol=="string"&&(t.protocol=lt(e.protocol,s)),typeof e.username=="string"&&(t.username=pt(e.username,s)),typeof e.password=="string"&&(t.password=ut(e.password,s)),typeof e.hostname=="string"&&(t.hostname=at(e.hostname,s)),typeof e.port=="string"&&(t.port=ft(e.port,t.protocol,s)),typeof e.pathname=="string"){if(t.pathname=e.pathname,r&&!rt(t.pathname,s)){let a=r.pathname.lastIndexOf("/");a>=0&&(t.pathname=y(r.pathname.substring(0,a+1),s)+t.pathname)}t.pathname=ct(t.pathname,t.protocol,s)}return typeof e.search=="string"&&(t.search=ht(e.search,s)),typeof e.hash=="string"&&(t.hash=ot(e.hash,s)),t}function A(t){return t.replace(/([+*?:{}()\\])/g,"\\$1")}function xt(t){return t.replace(/([.+*?^${}()[\]|/\\])/g,"\\$1")}function $t(t,e){e.delimiter??="/#?",e.prefixes??="./",e.sensitive??=!1,e.strict??=!1,e.end??=!0,e.start??=!0,e.endsWith="";let s=".*",r=`[^${xt(e.delimiter)}]+?`,a=/[$_\u200C\u200D\p{ID_Continue}]/u,u="";for(let o=0;o<t.length;++o){let i=t[o];if(i.type===3){if(i.modifier===3){u+=A(i.value);continue}u+=`{${A(i.value)}}${k(i.modifier)}`;continue}let h=i.hasCustomName(),n=!!i.suffix.length||!!i.prefix.length&&(i.prefix.length!==1||!e.prefixes.includes(i.prefix)),f=o>0?t[o-1]:null,w=o<t.length-1?t[o+1]:null;if(!n&&h&&i.type===1&&i.modifier===3&&w&&!w.prefix.length&&!w.suffix.length)if(w.type===3){let E=w.value.length>0?w.value[0]:"";n=a.test(E)}else n=!w.hasCustomName();if(!n&&!i.prefix.length&&f&&f.type===3){let E=f.value[f.value.length-1];n=e.prefixes.includes(E)}n&&(u+="{"),u+=A(i.prefix),h&&(u+=`:${i.name}`),i.type===2?u+=`(${i.value})`:i.type===1?h||(u+=`(${r})`):i.type===0&&(!h&&(!f||f.type===3||f.modifier!==3||n||i.prefix!=="")?u+="*":u+=`(${s})`),i.type===1&&h&&i.suffix.length&&a.test(i.suffix[0])&&(u+="\\"),u+=A(i.suffix),n&&(u+="}"),i.modifier!==3&&(u+=k(i.modifier))}return u}var Et=class{#n;#i={};#e={};#t={};#r={};#u=!1;constructor(t={},e,s){try{let r;if(typeof e=="string"?r=e:s=e,typeof t=="string"){let i=new bt(t);if(i.parse(),t=i.result,r===void 0&&typeof t.protocol!="string")throw new TypeError("A base URL must be provided for a relative constructor string.");t.baseURL=r}else{if(!t||typeof t!="object")throw new TypeError("parameter 1 is not of type 'string' and cannot convert to dictionary.");if(r)throw new TypeError("parameter 1 is not of type 'string'.")}typeof s>"u"&&(s={ignoreCase:!1});let a={ignoreCase:s.ignoreCase===!0},u={pathname:x,protocol:x,username:x,password:x,hostname:x,port:x,search:x,hash:x};this.#n=L(u,t,!0),z(this.#n.protocol)===this.#n.port&&(this.#n.port="");let o;for(o of S){if(!(o in this.#n))continue;let i={},h=this.#n[o];switch(this.#e[o]=[],o){case"protocol":Object.assign(i,$),i.encodePart=N;break;case"username":Object.assign(i,$),i.encodePart=mt;break;case"password":Object.assign(i,$),i.encodePart=dt;break;case"hostname":Object.assign(i,st),K(h)?i.encodePart=q:i.encodePart=Z;break;case"port":Object.assign(i,$),i.encodePart=B;break;case"pathname":V(this.#i.protocol)?(Object.assign(i,it,a),i.encodePart=gt):(Object.assign(i,$,a),i.encodePart=wt);break;case"search":Object.assign(i,$,a),i.encodePart=yt;break;case"hash":Object.assign(i,$,a),i.encodePart=vt;break}try{this.#r[o]=F(h,i),this.#i[o]=W(this.#r[o],this.#e[o],i),this.#t[o]=$t(this.#r[o],i),this.#u=this.#u||this.#r[o].some(n=>n.type===2)}catch{throw new TypeError(`invalid ${o} pattern '${this.#n[o]}'.`)}}}catch(r){throw new TypeError(`Failed to construct 'URLPattern': ${r.message}`)}}test(t={},e){let s={pathname:"",protocol:"",username:"",password:"",hostname:"",port:"",search:"",hash:""};if(typeof t!="string"&&e)throw new TypeError("parameter 1 is not of type 'string'.");if(typeof t>"u")return!1;try{typeof t=="object"?s=L(s,t,!1):s=L(s,H(t,e),!1)}catch{return!1}let r;for(r of S)if(!this.#i[r].exec(s[r]))return!1;return!0}exec(t={},e){let s={pathname:"",protocol:"",username:"",password:"",hostname:"",port:"",search:"",hash:""};if(typeof t!="string"&&e)throw new TypeError("parameter 1 is not of type 'string'.");if(typeof t>"u")return;try{typeof t=="object"?s=L(s,t,!1):s=L(s,H(t,e),!1)}catch{return null}let r={};e?r.inputs=[t,e]:r.inputs=[t];let a;for(a of S){let u=this.#i[a].exec(s[a]);if(!u)return null;let o={};for(let[i,h]of this.#e[a].entries())if(typeof h=="string"||typeof h=="number"){let n=u[i+1];o[h]=n}r[a]={input:s[a]??"",groups:o}}return r}static compareComponent(t,e,s){let r=(i,h)=>{for(let n of["type","modifier","prefix","value","suffix"]){if(i[n]<h[n])return-1;if(i[n]!==h[n])return 1}return 0},a=new O(3,"","","","",3),u=new O(0,"","","","",3),o=(i,h)=>{let n=0;for(;n<Math.min(i.length,h.length);++n){let f=r(i[n],h[n]);if(f)return f}return i.length===h.length?0:r(i[n]??a,h[n]??a)};return!e.#t[t]&&!s.#t[t]?0:e.#t[t]&&!s.#t[t]?o(e.#r[t],[u]):!e.#t[t]&&s.#t[t]?o([u],s.#r[t]):o(e.#r[t],s.#r[t])}get protocol(){return this.#t.protocol}get username(){return this.#t.username}get password(){return this.#t.password}get hostname(){return this.#t.hostname}get port(){return this.#t.port}get pathname(){return this.#t.pathname}get search(){return this.#t.search}get hash(){return this.#t.hash}get hasRegExpGroups(){return this.#u}};export{Et as URLPattern};