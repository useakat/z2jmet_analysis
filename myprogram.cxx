// $Modified: Thu Jun 24 09:56:51 2010 by uwer $
#include "Hathor.h"
#include "HathorPdf.h"
#include <iostream>
#include <fstream>

using namespace std;

int main(){
<<<<<<< HEAD
  double mt = 650;
=======
  double mt = 600;
>>>>>>> master
  double mur,muf;
  mur = mt;
  muf = mt;
  double val,err,chi,pdfup,pdfdown;

  //  unsigned int scheme = Hathor::LO;
  //  unsigned int scheme = Hathor::LO  | Hathor::NLO;
  unsigned int scheme = Hathor::LO | Hathor::NLO | Hathor::NNLO;
  double ecms=8000.;
  Lhapdf lhapdf("MSTW2008nlo68cl");
  Hathor XS(lhapdf);

  for(int i=0;i<1;i++){
    XS.setColliderType(Hathor::PP);
    XS.setSqrtShad(ecms);
    XS.setScheme(scheme);
    XS.setPrecision(Hathor::MEDIUM);
   
    XS.getXsection(mt,mur,muf);
    XS.getResult(0,val,err,chi);

    XS.setScheme(  scheme | Hathor::PDF_SCAN );
    XS.setPrecision(Hathor::LOW);
    XS.getXsection(mt,mur,muf);
    XS.getPdfErr(pdfup,pdfdown);

    cout << XS.getAlphas(mur) << " " << val << " " << err << " "
	<< pdfup << " " << -pdfdown << " (pdf)"
	<< endl;
  }
}
