#include "kuznechik_gpu.cuh"
#include "cuda.h"
#include <stdexcept>
#include <iostream>
#include <device_launch_parameters.h>
#include "check.hpp"

#pragma once
#ifdef __INTELLISENSE__
void __syncthreads();
#endif

struct kuznechik_keys {
	kuznechik::block block[10];
};

const __device__ unsigned char _s[256] =
{
	252, 238, 221, 17, 207, 110, 49, 22, 251, 196,
	250, 218, 35, 197, 4, 77, 233, 119, 240, 219,
	147, 46, 153, 186, 23, 54, 241, 187, 20, 205,
	95, 193, 249, 24, 101, 90, 226, 92, 239, 33,
	129, 28, 60, 66, 139, 1, 142, 79, 5, 132, 2,
	174, 227, 106, 143, 160, 6, 11, 237, 152, 127,
	212, 211, 31, 235, 52, 44, 81, 234, 200, 72,
	171, 242, 42, 104, 162, 253, 58, 206, 204, 181,
	112, 14, 86, 8, 12, 118, 18, 191, 114, 19, 71,
	156, 183, 93, 135, 21, 161, 150, 41, 16, 123,
	154, 199, 243, 145, 120, 111, 157, 158, 178, 177,
	50, 117, 25, 61, 255, 53, 138, 126, 109, 84,
	198, 128, 195, 189, 13, 87, 223, 245, 36, 169,
	62, 168, 67, 201, 215, 121, 214, 246, 124, 34,
	185, 3, 224, 15, 236, 222, 122, 148, 176, 188,
	220, 232, 40, 80, 78, 51, 10, 74, 167, 151, 96,
	115, 30, 0, 98, 68, 26, 184, 56, 130, 100, 159,
	38, 65, 173, 69, 70, 146, 39, 94, 85, 47, 140,
	163, 165, 125, 105, 213, 149, 59, 7, 88, 179,
	64, 134, 172, 29, 247, 48, 55, 107, 228, 136,
	217, 231, 137, 225, 27, 131, 73, 76, 63, 248,
	254, 141, 83, 170, 144, 202, 216, 133, 97, 32,
	113, 103, 164, 45, 43, 9, 91, 203, 155, 37,
	208, 190, 229, 108, 82, 89, 166, 116, 210, 230,
	244, 180, 192, 209, 102, 175, 194, 57, 75, 99,
	182
};

const __device__ unsigned long long _l1[16][16][2] =
{ { {0, 0},
{8811411909822803663, 10701921678501830072},
{17622823819633220701, 16990807200640187059},
{10293175507279524498, 9173731492116424459},
{3162497854892506042, 1537401207488559013},
{5884831944477185397, 9354309921882761757},
{16101402139914053607, 18347255176535084310},
{11906329519187347752, 7645518359503917230},
{6198613445220890295, 3074313129060707721},
{3192359874067142776, 13704166213001474097},
{11715339218449214186, 13934522763763324730},
{15626736994648605733, 6189498057605925506},
{9072102451935743245, 4611639564336306732},
{553654060880159682, 12356479694973978516},
{9905190165529448784, 15291036715740405919},
{17527483683738566559, 4661350890271079719}},
{ {0, 0},
{16633331581385711768, 2318678611682382921},
{1110678437088149747, 4637283825573784466},
{16842506947513770091, 6951139966317674459},
{2220867591501938725, 9274073962864301799},
{17872374304749822141, 11572483901748544174},
{1277886952501526742, 13902278021374852469},
{17829330480097255502, 16195869887440841020},
{4352507610055820106, 14099435918816603917},
{15758728889062908882, 16395033032650505028},
{3679118443339875257, 9507577469424567455},
{15410099979747107617, 11807359311578976470},
{2500955550576624495, 4836693815417616874},
{14150410224961414135, 7148051053476605347},
{3304729488645555100, 235755598974997112},
{14630426108448875268, 2551301963466212913}},
{ {0, 0},
{5648336827259012724, 9616440642146056327},
{11296184371839324136, 14549136310309729229},
{15179091986029906332, 5520462838189067082},
{18107626578222095891, 5842039283950396761},
{13054204706981566567, 15305309709112909278},
{7462233381788766715, 11023683398148429460},
{3021284034603063183, 2130071186367622675},
{3861393433414532902, 11684077203145460146},
{8931905478279379282, 2833427857970508085},
{12200945219436261582, 7768362100669692543},
{16658985874116605626, 17202257424056615672},
{14906170061158572341, 17524976785790610667},
{9277334808322418497, 8521175916451894380},
{5915831499925892829, 4241779429027323686},
{2052424326285748393, 13810752504306411425}},
{ {0, 0},
{1879985431382121151, 1195365785282293524},
{3759969501259528125, 2373211673114730024},
{3330716064304639234, 3492996332236861756},
{7519939002489892537, 4620041081665600592},
{8235742744785662982, 5803842753390154564},
{6661431849432357124, 6985920384456712824},
{5072500357378294715, 8098654425269914988},
{15039877193230852017, 9239872439054678944},
{14605011230733550862, 10424801651367777460},
{16471485489571325964, 11589389625828238728},
{18339066711524160179, 12700998325084539548},
{13322861770394956040, 13846090441199781872},
{11741830888142744503, 15038076868899973348},
{10145000714752329397, 16197308849495300568},
{10870920582217948170, 17320470667167889100}},
{ {0, 0},
{13476675676659028115, 14005517490035789259},
{13045882760765432805, 5168704265819314517},
{1011775410858914678, 9648815790369952926},
{12184649872189883657, 10283716080319361450},
{1305577288503104922, 5542399220066221153},
{2023483751496148716, 14487504334761011455},
{12038718702759933567, 815261057882137908},
{10462116762857376274, 16117594253819962007},
{3041656960927570561, 2157406086226407260},
{2611153765257374199, 10959474170972617666},
{11473601351800224100, 6506092063165953545},
{4046613198242385691, 5844031700672746301},
{9452686609507786632, 10612657950791180022},
{10170319844918291710, 1630521848452893288},
{3900954158997273709, 15347512202610788259}},
{ {0, 0},
{3327523417489623182, 13868628981575324301},
{6654837098841280735, 4895000391134487769},
{8248070030924044369, 9482835338931222100},
{13309461991934387069, 9664675413635582065},
{10851715503094541299, 5073471561131842300},
{16496138150566523810, 14263282643550039208},
{14610718241719991084, 398040161016315429},
{12946627734336767482, 14933484647725043938},
{11350783823485750644, 1101448687656796783},
{17289620517700736293, 10146871374835004475},
{13969232192511466923, 5523569651182905014},
{801390589618873991, 5269693424010123411},
{2680381293770944009, 9896364050217552414},
{6288616536690423384, 778910340907662410},
{8748272517020860118, 14607559808380956359}},
{ {0, 0},
{17421241685292911090, 103400537708162731},
{2399183868876345639, 206801072165560213},
{15028285486015994069, 266255841738682686},
{4798296269496803662, 324166765773930217},
{12921484881970391228, 365057415514476610},
{7196017785284636777, 477697730297733500},
{10527668866678798747, 562463641719656407},
{9578928879375008412, 648119411275824145},
{8443015729434610542, 689559911604720314},
{11935854114620576699, 729619771623498628},
{6079862893309106761, 815005764368567599},
{14301682099807101906, 901070528097305336},
{4016479806056835616, 1003850691854052435},
{16659471553811477237, 1035698883634224493},
{1654784920275712775, 1094604060887397318}},
{ {0, 0},
{13756085239261404403, 18149190590855247433},
{13766902129062509349, 3854803779439374226},
{138118656717318102, 14889431647766763995},
{13626339779127555402, 7709607279705874151},
{287409526322735545, 10457611593145100462},
{150773137929850479, 6881787634280264053},
{13614603752707281564, 11844438206931699516},
{13345562530238130836, 15293956266322803725},
{563962387752875623, 3450298955312548420},
{448436788098077105, 16230990291150476191},
{13321159817006812482, 1918233290425198038},
{301334066848292830, 13745279395044909802},
{13459538657201144621, 4980957444502721699},
{13484711007710455035, 10069496081289629048},
{415526966272866312, 8097729394002180913}},
{ {0, 0},
{15336343934861426954, 95754800939141129},
{7739864604074918164, 191509594341314578},
{13815959899774943262, 287193046830749723},
{15479656360114749992, 329818506802831396},
{146203145547039522, 416565737710233645},
{13671605379631465276, 449129442386522166},
{7597272567721820726, 535805909496641599},
{8027474893950011216, 640992594933465160},
{13525139193258313306, 698466022573623361},
{292404379833632324, 742288719815463002},
{15049754204704950094, 799692208057178195},
{13381769627688781176, 898049698386894956},
{7881364347969176690, 946515729941489765},
{15194051447227483244, 1071543931716792446},
{435088603301856614, 1119940539805890679}},
{ {0, 0},
{12676473880427324607, 13885907166196356204},
{11318954799380482237, 4876148515633277144},
{3674621460055698434, 9448316457712745652},
{17954165986274792377, 9697900892505543539},
{6251527355717400326, 5053456071764723487},
{7223496440688515844, 14212887941455428523},
{14687613226987487163, 399400591036346311},
{3554470882696930993, 14981639724500510182},
{11439114172566979086, 1107286322589249930},
{12412207563189808652, 10106911858966744382},
{264275113602124467, 5545708185098787154},
{14446992049206064392, 5295288195683415701},
{7464126414832439735, 9928188066485773049},
{6155021917479189941, 781141110811123277},
{18050680220338641162, 14583655378672060961}},
{ {0, 0},
{4006392519141144822, 14018915524615540522},
{7994420725616259887, 5177277858226445908},
{6442526328616913881, 9607395907448213886},
{15861965505968514398, 10264200887424138408},
{16985490176881991080, 5547578461255709570},
{12885052372675466865, 14531047383120159484},
{9604337532364959367, 803215233279864278},
{8881673439900043708, 16132539993348667539},
{5538189677505491274, 2121048925317068729},
{1563850388680161939, 10969406871814891207},
{2461913601230996069, 6536438343015229933},
{12061501243194027234, 5878200222596613179},
{10446837920084235284, 10601120105919499025},
{14524931451170037709, 1606357064457345647},
{18305862507385005883, 15332465734127211845}},
{ {0, 0},
{12788067904468495785, 1211982396912497409},
{11669020159616899729, 2333258102775686402},
{1191457204708669240, 3508504703765960195},
{9305460496535631073, 4666514269578086916},
{3484654738514155848, 5769983656282077445},
{2365255147765493360, 6963602829214838534},
{10496565850974372825, 8102675506274475015},
{13926965167328766721, 9243452426352890888},
{8088145012681180840, 10418660557329688329},
{6968815793136529808, 11539967049543692554},
{15118140896738270265, 12751908751581987339},
{4640156827994103776, 13872666863454051852},
{17374181534513902153, 15011709849362509069},
{16255063418957415793, 16205351012536285966},
{5831543657157388504, 17308788517723375631}},
{ {0, 0},
{15299306711213377258, 9603045850884773984},
{7756356112399322903, 14521995146050925504},
{13832263848501070333, 5533977221750418336},
{15459512092666191150, 5896331813132838211},
{205254846862252996, 15318754272541719843},
{13632154854117118521, 10978517155830683267},
{7601278991069811923, 2098493248461295331},
{8058471001823033948, 11701820596890323590},
{13512908618364435638, 2819790508249436902},
{320156226187916619, 7776953982889539910},
{14997938941331567521, 17197440633933275430},
{13357193779720480626, 17561449601685352389},
{7857733086284636568, 8570932884639578021},
{15202556070879176805, 4196986493751696389},
{479732686486351503, 13797463178984555621}},
{ {0, 0},
{3095383467436819598, 2322811739018152078},
{6064383291646052575, 4645621566775776223},
{9141188646111595601, 6936907696085441361},
{12128766583292089213, 9291176062314849917},
{9414504744177670131, 11586824639290765043},
{18193148912857013154, 13873465462961206690},
{15460310335160852268, 16191632175512894764},
{10638645982134494714, 14061088835396538362},
{13353475238108799348, 16365884457918220148},
{14379171581507398949, 9465323966808054821},
{17111451538709260715, 11774622776640214187},
{4320668199650834055, 4887503642319792519},
{1225852149073965577, 7201165999329960201},
{8061193386715201112, 264435404620855896},
{4983829411755424470, 2564587100187833046}},
{ {0, 0},
{7932742528751882317, 10711077298077073227},
{15865132106775880602, 16972316688232480406},
{12842725536717779927, 9163888558055195101},
{8888006641535600375, 1572129229373259759},
{1535245611138881210, 9328141450043408548},
{12066497360991069549, 18327569308412723577},
{14511174314707678496, 7709598663888649778},
{17775944284421508909, 3053904991201361437},
{10999501583870828384, 13746325702963822934},
{3070490388001270967, 13972539280155639947},
{4938850039980293370, 6146580609599602624},
{10225526129429481946, 4589437798520734194},
{16428742877153941911, 12327919332783177401},
{5891860937825839680, 15292321382484131684},
{4598978973584079373, 4655694297674399791}},
{ {0, 0},
{13293016880751485550, 113861975594575709},
{12967148488334542812, 210485528703356602},
{832841251242517938, 252007670754863591},
{11901856523503783291, 294235849618463927},
{2112657851883024149, 396828243321994218},
{1648163170943453863, 504014529760907789},
{12584530462283786441, 534268464357307728},
{9896103716966521334, 588469787963816877},
{3543292263616543640, 702050245610888432},
{4225103498021887530, 775007669925229847},
{9428529166315977796, 816811261204730442},
{3205972037871703181, 882705345503323930},
{10666686628788647651, 985016221301555271},
{11495849601114641233, 1068536928701852064},
{2878712900618793279, 1099072312484040445}},
};

const __device__ unsigned long long _l2[16][16][2] =
{ { {0, 0},
{12396737607767306157, 6095427222262618577},
{11174589942353845913, 12172557191264006497},
{3971631114322538804, 18193085118763985072},
{17665436266911350001, 10599779769221652930},
{6422752764215923548, 14379629988613830675},
{7943262225474183784, 4320192083471028387},
{13994423215285915077, 8026304092446607730},
{2977011999039929121, 16515321983243338311},
{9609124213334709388, 12800772841756613526},
{12845505266438825400, 5611390106381431590},
{2183799242849307157, 1821960387607931639},
{15886522536449804240, 8515126422585435013},
{8102621417740576893, 2503016910120745556},
{5146587753654475081, 16052608184888955620},
{16962338947965482724, 9966779179483532085}},
{ {0, 0},
{8705014958114293140, 5014059480953183770},
{17320800416979061483, 10009755756188630836},
{9840845458067738495, 14950912118662078766},
{2575622938656167701, 15497261688580144744},
{6588800963198292609, 10557794244849967218},
{15267672637120929278, 6771336545801437532},
{12335297413799876714, 1760091883498463046},
{5098047105594256682, 7864035685599821776},
{4499529438529726654, 2933864543824699850},
{13177601647223695297, 16702550407014465764},
{14856902496131195477, 11700041295736315646},
{7278263117775485503, 13417348845008503224},
{2148209625550880683, 18421546737314176930},
{10763125422274916564, 3520183766967500428},
{17118218950659896640, 8453169589677023382}},
{ {0, 0},
{7705615530709171532, 9749269129871872423},
{15284500246291118744, 14814794382034690445},
{13759248384360335316, 5392185760072904746},
{7726741271294375155, 6481721367074030297},
{132080209909172671, 16050811081541555070},
{13774142644975603307, 10694654669854122836},
{15404648004077204263, 1380167867111142131},
{15452993258869828389, 12836848256323503985},
{13590692700165117545, 3848882117038610134},
{173806952294142397, 9204545672905238268},
{7531888843312295153, 17938190375983380315},
{13641096788305305558, 16993794741889959336},
{15537754334414496410, 7825649599618569231},
{7589579942583969102, 2760335728832537637},
{269163473819310082, 11602101838711633282}},
{ {0, 0},
{7184298026667359905, 14084160173519123843},
{14313920903884864641, 5037338979119049157},
{11895840345781715488, 9699843280276102214},
{5731259827241416897, 9949421588212322633},
{3186937267490702944, 5289353753146696906},
{9884492211392382016, 14986654805452208268},
{16906237805500611297, 905142341968235791},
{11444156709763822401, 15503329940081598866},
{18258172439620750816, 1464260858819531793},
{6373874255808450496, 10578636032639715415},
{4307495270208532833, 5889055072111623636},
{15084887861701430144, 6716439659163054299},
{12892549453237253409, 11403513681507370328},
{1728549578888230657, 1791781002752612638},
{8380858413512690080, 15828272914791361693}},
{ {0, 0},
{16239994846357427236, 9050375888946005997},
{126129969685211208, 18082453974942092825},
{16185963238692830316, 9757238801157392884},
{163032109756141712, 3972547787870903346},
{16366988770285733044, 5384114660568734687},
{253096981203876056, 14830524270878724651},
{16348949658425257212, 12702965511028872646},
{326062840798355683, 7945095575741806692},
{16566039502262547655, 1430951433338699657},
{380117555536431275, 10715029164321683069},
{16439967824026049679, 16801253087556350352},
{487898088921559155, 6441261816534344790},
{16691837749972296791, 2664602199345210299},
{505887705429497915, 11786550706634697295},
{16601758567540968479, 15999980511555759522}},
{ {0, 0},
{11931602942080715319, 6736481608251794183},
{9937722075952649326, 13472614665911207182},
{3205560436540644953, 16682632627803907593},
{15064824314990504156, 13201086882268973596},
{8395994266133275371, 16883824335867537691},
{6411120869910396082, 994162178454785810},
{18261377264444782213, 5816173996279983125},
{6999159010034798715, 12494850025164051512},
{14174960674087852620, 17301235139214571327},
{16774751488477905941, 1702017946172526902},
{5575018951589776930, 5395877610565202481},
{12696496089272187047, 1897477201102183972},
{1560095143003845264, 5127905777454284067},
{4168893444342901961, 11578023322054695722},
{11263348561057244926, 18289589273110706221}},
{ {0, 0},
{14635962257864083451, 1170910986421598242},
{6141436822087437877, 2341328288884208452},
{11396260316569782734, 3477334140482145126},
{12282525098988855146, 4682655764925081224},
{7019187263553640593, 5819719226441178794},
{18396799583742742879, 6954177087008626124},
{3770618862572738212, 8123889416768695790},
{10946164662816243156, 9240054880634522835},
{6698529276613573167, 10377610360719357169},
{14038373714335036385, 11548730663436943255},
{706837144183616538, 12716683272081573813},
{4439666614695404222, 13891184200437901915},
{17762688839330555205, 15057942825362281081},
{7540742129926155403, 16193105610313210143},
{11798159040206433136, 17331714577164427581}},
{ {0, 0},
{12783520123159172331, 7745655221594733338},
{11659923235464112917, 15491310437782893876},
{1204837925508661246, 13655521715828297262},
{9323503248672478762, 8015105839401707880},
{3462022487312106177, 307784268266803826},
{2356476248231492927, 13386756995980926044},
{10510220087029295572, 15184247801604646726},
{13963053715677278036, 16030211677767569872},
{8119590513944935359, 13044914863504763594},
{6923973506355758145, 615568536533607652},
{15095726108696957098, 7202636998290677758},
{4658137711116728702, 12776044590529853624},
{17423626805587438997, 15723113857223787426},
{16245990145514263147, 7471911694240615820},
{5772900195157804672, 923106514179274390}},
{ {0, 0},
{16054947876639493536, 1155602925311459472},
{9178203060471044739, 2311137961194669027},
{11642127235892500259, 3466444636824421235},
{18356334652665231301, 4621922150198625541},
{2337490371527817829, 5777514732152866197},
{9358842943593147718, 6932889266115872486},
{6858955937001513190, 8088206214231688822},
{4593488244621585737, 9243843471468562954},
{16245041580750692585, 10394655478602074778},
{4674980739863656394, 11554676515750758889},
{11398184258055961194, 12705766905467160953},
{13907560010173897356, 13865711461993271055},
{2292110259849107244, 15016515874552827807},
{13717422590238146575, 16176411611329072364},
{6958256231246073263, 17327509524756663420}},
{ {0, 0},
{7108941765389815713, 6706407587009857807},
{14164683391181380993, 13412325891332706846},
{11978194717746811424, 16659894180396145425},
{5468813598853331393, 13205766509484385340},
{2976079050164270688, 16885609667213143347},
{10337503325842809920, 965575694530131490},
{17140199215976688609, 5798274368866697005},
{10811243021903131201, 12504416557895600248},
{17627450550159900128, 17337009945523274103},
{5952158095005790144, 1705381900677831270},
{3472935700653318241, 5384979033974723433},
{15991262760047381376, 1931149477799816260},
{13782255244906923041, 5178330455451460939},
{1837311135908582913, 11596475890788826714},
{8923733543378278816, 18302355428596283221}},
{ {0, 0},
{17763344948188860859, 9009335124137406693},
{3443890572678357429, 18018602893561766665},
{15658800567831605262, 9730441865877771244},
{6797427674573554345, 3971081380835968530},
{12164579286583022354, 5340015672901351159},
{8187113449488294684, 14777140116052141339},
{9735212651055968935, 12688157662339044862},
{13594855345909024657, 7942162754176650276},
{5345408772803958314, 1387016866741976257},
{10619919832452507172, 10679957966286401325},
{7342447183053191071, 16803286041924624328},
{16357056925393192248, 6423302450415716918},
{1476024547800077443, 2604119641114819283},
{14786681686408619149, 11757430051488917823},
{4301162748587160886, 16009556537594288602}},
{ {0, 0},
{4723371180206036226, 14091391616362998544},
{9429219443600189700, 5034917765274015008},
{14075886493075864582, 9678571002011713072},
{14372572183333376264, 9979410594768104000},
{9725922863541683210, 5328694129823564112},
{5021218229763307532, 14961628767709708128},
{297864779257507086, 877300448541922416},
{5614448872794235408, 15562814272472568960},
{893487959850989330, 1473969159537737616},
{14929950226226662164, 10531005995082924448},
{10285411969036934678, 5884806323905145520},
{9988744008186278680, 6739571078642237120},
{14633299995076240922, 11387749905239676368},
{595729558502627868, 1754252351885110240},
{5316708201129856798, 15841118378387996912}},
{ {0, 0},
{16026587724373079992, 9784754541898339535},
{9210428576846556595, 14796537896248208221},
{11654158473229179403, 5376650049722220434},
{18331627650169608613, 6462238199630796218},
{2310037261471854109, 16024956526293254517},
{9346382944859403286, 10734795583946424039},
{6907648109966885806, 1383671460244187688},
{4597625953461268873, 12871277628634114743},
{16260225484288706097, 3843145700327472760},
{4619584428491365434, 9207655741518889450},
{11418295284795698050, 17870921541389931813},
{13954696237710731308, 16947482632359198477},
{2288086808935718804, 7853120790749948866},
{13725574970475660703, 2766988612500575312},
{6922851942038598183, 11649755684212850847}},
{ {0, 0},
{16540349578034465335, 4991688623113559351},
{708543558458496878, 9983377246227036526},
{17032157297000422745, 14972813914908042329},
{1326733381993344732, 15554070470812299996},
{17862015774757709035, 10564638732821082091},
{1998683885618264498, 6725910647583574962},
{18318356476304044933, 1734226989519623813},
{2653397765337030523, 7887298958996809595},
{13932417039956989260, 2896758793295297100},
{3244706819883780117, 16715466444581920277},
{14451105520430547490, 11727178198953132834},
{3943820454424687015, 13451821295167133095},
{15217772543774686096, 18440114471485704336},
{4570594323055797961, 3468453979039247561},
{15773051875746557182, 8458999109790364158}},
{ {0, 0},
{3432707508134256218, 6107602169386695738},
{6811090344739930036, 12125903941383175028},
{8153406341314535918, 18196040801586628430},
{13603536001281572267, 10632569665329395432},
{10622331953078641649, 14361123888681683666},
{16306599115380277791, 4308155548494876060},
{14839290632397675589, 8001536944844091814},
{13497831333417941653, 16564224377719745555},
{10732785309556925647, 12762495041871220777},
{16560919461521229089, 5591270807490713447},
{14589228246873348987, 1826949606077639517},
{547356672790841150, 8525748992839293691},
{2899179843219085668, 2491339803021698753},
{6421362768870619274, 16003073889684136335},
{8556327057097434832, 10003859517227490741}},
{ {0, 0},
{15108461910207279663, 1176731767193810329},
{7033237363641329502, 2353392060742068977},
{12697650734715639153, 3529831252565712744},
{14048178853775642044, 4653091408150909985},
{1394183164705849235, 5820777952677257656},
{11776416196250512098, 6934404777967140560},
{8269231436008495309, 8101803282609048393},
{5127718129814133179, 9287885013351820098},
{10846174747147529108, 10426296560374734555},
{2788366328388288229, 11551134538671522227},
{17806756193160580298, 12689253583439410218},
{9645716735702422535, 13868320267870388067},
{6084488764098995752, 14997756969694169850},
{16449235299060282201, 16203606565218080146},
{3885311620525670774, 17332755300272562187}},
};

extern "C" __global__ void encrypt_kernel_kuz(kuznechik::block * data, size_t n, kuznechik_keys k)
{
	auto tid = threadIdx.x + blockIdx.x * blockDim.x;
	auto tcnt = blockDim.x * gridDim.x;

	__shared__ unsigned char S[256];
	__shared__ unsigned long long L1[16][16][2];
	__shared__ unsigned long long L2[16][16][2];
	__shared__ kuznechik_keys keys;

	if (threadIdx.x == 0) {
		keys = k;

		for (int i = 0; i < 256; ++i)
			S[i] = _s[i];

		for (int i = 0; i < 16; ++i)
			for (int j = 0; j < 16; ++j)
				for (int q = 0; q < 2; ++q)
				{
					L1[i][j][q] = _l1[i][j][q];
					L2[i][j][q] = _l2[i][j][q];
				}
	}

	__syncthreads();

	for (int k = tid; k < n; k += tcnt)
	{
		auto src = keys.block[k % 10];
		for (int j = 0; j < 10; ++j)
		{
			src.ull[0] ^= keys.block[j].ull[0];
			src.ull[1] ^= keys.block[j].ull[1];
			auto tmp = src;
			for (int i = 0; i < 16; ++i)
			{
				auto tmp_c = S[tmp.c[i]];
				auto tmpl1 = tmp_c & 0x0F;
				auto tmpl2 = tmp_c & 0xF0 >> 4;
				src.ull[0] ^= L1[i][tmpl1][0];
				src.ull[0] ^= L2[i][tmpl2][0];

				src.ull[1] ^= L1[i][tmpl1][1];
				src.ull[1] ^= L2[i][tmpl2][1];
			}
		}
		data[k].ull[0] ^= src.ull[0];
		data[k].ull[1] ^= src.ull[1];
	}
}

static kuznechik_keys k;
static CUfunction function;

void kuznechik_gpu::encrypt(block* buf, size_t size) const
{
	block* data;
	check(cuMemAlloc((CUdeviceptr*)&data, size * sizeof(block)));
	check(cuMemcpy((CUdeviceptr)data, (CUdeviceptr)buf, size * sizeof(block)));

	void* args[3] = { &data, &size, &k };
	check(cuLaunchKernel(function, 10, 1, 1, 1024, 1, 1, 9000, 0, args, 0));

	check(cuCtxSynchronize());
	check(cuMemcpy((CUdeviceptr)buf, (CUdeviceptr)data, size * sizeof(block)));
	check(cuMemFree((CUdeviceptr)data));
}

kuznechik_gpu::kuznechik_gpu(const std::array<unsigned int, 8>& key) : kuznechik(key)
{
	for (int i = 0; i < 10; ++i)
	{
		k.block[i].ull[0] = keys[i].ull[0];
		k.block[i].ull[1] = keys[i].ull[1];
	}

	CUmodule module;

	check(cuModuleLoad(&module, "\\x64\\Release\\kuznechik_gpu.ptx"));
	check(cuModuleGetFunction(&function, module, "encrypt_kernel_kuz"));
}
