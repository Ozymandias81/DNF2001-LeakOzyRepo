#include <conapp.h>
#include <ximage.h>

class TestApp : public XConApp
{
protected:
	U32 main(void);
public:
	TestApp(void){}
};

TestApp _testapp;

U32 TestApp::main(void)
{
	XLoadBMPDevice("f:\\duke4\\ximage\\images\\true.bmp",null,IMG_FORMAT_ARGB_1555);
	XLoadBMPDevice("f:\\duke4\\ximage\\images\\indexed.bmp",null,IMG_FORMAT_ARGB_1555);
	return TRUE;
}