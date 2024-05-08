const lf = '\x0A';
const esc = '\x1B';
const gs = '\x1d';

const cut = '${gs}VB\x00';
const reset = '$esc@';

const align = '${esc}a';
const rotation = '${esc}V';
const printMode = '$esc!';
const characterSize = '$gs!';
const upsideDown = '$esc{';
const inverted = '${gs}B';

const qrCodeSize = '$gs(k\x03\x00\x31\x43';
const qrCodeCorrection = '$gs(k\x03\x00\x31\x45';
const qrGeneric = '$gs(k';

const barcodeTextPosition = '${gs}H';
const barcodeHeight = '${gs}h';
const barcodeWidth = '${gs}w';
const barcodeData = '${gs}k';

const bitImage = '$esc*';
