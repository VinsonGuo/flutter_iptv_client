const m3u8Url = 'https://iptv-org.github.io/iptv/index.m3u';
const channelCountries = ["all","AD","AE","AF","AG","AI","AL","AM","AO","AR","AS","AT","AU","AW","AZ","BA","BB","BD","BE","BF","BG","BH","BI","BJ","BM","BN","BO","BQ","BR","BS","BT","BW","BY","BZ","CA","CD","CF","CG","CH","CI","CK","CL","CM","CN","CO","CR","CU","CV","CW","CY","CZ","DE","DJ","DK","DM","DO","DZ","EC","EE","EG","EH","ER","ES","ET","FI","FJ","FM","FO","FR","GA","GD","GE","GF","GH","GI","GL","GM","GN","GP","GQ","GR","GT","GU","GW","GY","HK","HN","HR","HT","HU","ID","IE","IL","IN","IQ","IR","IS","IT","JM","JO","JP","KE","KG","KH","KI","KM","KN","KP","KR","KW","KY","KZ","LA","LB","LC","LI","LK","LR","LS","LT","LU","LV","LY","MA","MC","MD","ME","MG","MK","ML","MM","MN","MO","MP","MQ","MR","MT","MU","MV","MW","MX","MY","MZ","NA","NC","NE","NG","NI","NL","NO","NP","NU","NZ","OM","PA","PE","PF","PG","PH","PK","PL","PM","PR","PS","PT","PW","PY","QA","RE","RO","RS","RU","RW","SA","SB","SC","SD","SE","SG","SI","SK","SL","SM","SN","SO","SR","SS","ST","SV","SX","SY","SZ","TC","TD","TG","TH","TJ","TL","TM","TN","TO","TR","TT","TW","TZ","UA","UG","UK","US","UY","UZ","VA","VC","VE","VG","VI","VN","VU","WS","XK","YE","YT","ZA","ZM","ZW"];
const channelCategories = ["favorite", "all", "animation","auto","business","classic","comedy","cooking","culture","documentary","education","entertainment","family","general","kids","legislative","lifestyle","movies","music","news","outdoor","relax","religious","science","series","shop","sports","travel","weather","xxx"];
const channelLanguage = ["all", "spa","fra","dan","por","bul","rus","nld","eng","ell","tel","ita","aze","pus","deu","tha","pol","hun","zho","ukr","lav","kaz","prs","kat","fas","tam","ara","sqi","slk","cat","srp","slv","tur","ron","mal","urd","eus","lit","mya","kur","pan","heb","hye","ben","amh","uzb","kor","hin","mar","ces","wol","fil","nep","kan","jpn","swa","guj","ind","sin","aar","hau","ibo","yor","swe","mon","vie","tgl","ori","kir","bos","fin","mkd","hbs","div","est","isl","tuk","cmn","pes","mlg","glg","ltz","cnr","som","tir","yue","asm","msa","hrv","snd","tig","bho","tgk","khm","dzo","nor","prd","bel","kin","urk","its","jav","gle","lao","nan","hue","gmy","mlt","pap","smo","afr","orm","rom","ewe","gsw","swh","tet","kok","far","hat","hmn","kik","srb","kam","aii","man","kal","fao","kmr","ckb","lug","zul","cro","oci","dhw","war","gom","fuc","lld","luo","run","lah","mos","cym","crs","bod","syr","bak","mri","sat","nob","yua","aym","lat","uig"];
const Map<String, String> isoMapping = {
  "spa": "es", "fra": "fr", "dan": "da", "por": "pt", "bul": "bg",
  "rus": "ru", "nld": "nl", "eng": "en", "ell": "el", "tel": "te",
  "ita": "it", "aze": "az", "pus": "ps", "deu": "de", "tha": "th",
  "pol": "pl", "hun": "hu", "zho": "cn", "ukr": "uk", "lav": "lv",
  "kaz": "kk", "prs": "fa", "kat": "ka", "fas": "fa", "tam": "ta",
  "ara": "ar", "sqi": "sq", "slk": "sk", "cat": "ca", "srp": "sr",
  "slv": "sl", "tur": "tr", "ron": "ro", "mal": "ml", "urd": "ur",
  "eus": "eu", "lit": "lt", "mya": "my", "kur": "ku", "pan": "pa",
  "heb": "he", "hye": "hy", "ben": "bn", "amh": "am", "uzb": "uz",
  "kor": "ko", "hin": "hi", "mar": "mr", "ces": "cs", "wol": "wo",
  "fil": "fil", "nep": "ne", "kan": "kn", "jpn": "ja", "swa": "sw",
  "guj": "gu", "ind": "id", "sin": "si", "aar": "aa", "hau": "ha",
  "ibo": "ig", "yor": "yo", "swe": "sv", "mon": "mn", "vie": "vi",
  "tgl": "tl", "ori": "or", "kir": "ky", "bos": "bs", "fin": "fi",
  "mkd": "mk", "hbs": "sh", "div": "dv", "est": "et", "isl": "is",
  "tuk": "tk", "cmn": "zh", "pes": "fa", "mlg": "mg", "glg": "gl",
  "ltz": "lb", "cnr": "cnr", "som": "so", "tir": "ti", "yue": "zh",
  "asm": "as", "msa": "ms", "hrv": "hr", "snd": "sd", "tig": "ti",
  "bho": "bho", "tgk": "tg", "khm": "km", "dzo": "dz", "nor": "no",
  "prd": "fa", "bel": "be", "kin": "rw", "urk": "uz", "its": "it",
  "jav": "jv", "gle": "ga", "lao": "lo", "nan": "zh", "hue": "hue",
  "gmy": "gmy", "mlt": "mt", "pap": "pap", "smo": "sm", "afr": "af",
  "orm": "om", "rom": "ro", "ewe": "ee", "gsw": "gsw", "swh": "sw",
  "tet": "tet", "kok": "kok", "far": "fa", "hat": "ht", "hmn": "hmn",
  "kik": "ki", "srb": "sr", "kam": "kam", "aii": "aii", "man": "man",
  "kal": "kl", "fao": "fo", "kmr": "ku", "ckb": "ckb", "lug": "lg",
  "zul": "zu", "cro": "hr", "oci": "oc", "dhw": "dhw", "war": "war",
  "gom": "gom", "fuc": "fuc", "lld": "lld", "luo": "luo", "run": "rn",
  "lah": "lah", "mos": "mos", "cym": "cy", "crs": "crs", "bod": "bo",
  "syr": "syr", "bak": "ba", "mri": "mi", "sat": "sat", "nob": "nb",
  "yua": "yua", "aym": "ay", "lat": "la", "uig": "ug"
};
