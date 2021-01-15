import 'package:ai_radio/model/radio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ai_radio/utils/ai_utils.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<MyRadio> radios;
  MyRadio _selectedRadio;
  //Color _selectedColor;
  bool _isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchRadios();
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assest/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    print(radios);
    setState(() {});

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  _playMusic(String url) {
    _audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .color(AiColor.primaryColor1)
              .make(),
          AppBar(
            title: "Radio 26".text.xl4.extraBold.white.make(),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ).h(100.0).p16(),
          radios != null
              ? VxSwiper.builder(
                  itemCount: radios.length,
                  aspectRatio: 1.0,
                  enlargeCenterPage: true,
                  itemBuilder: (context, index) {
                    final red = radios[index];

                    return VxBox(
                            child: ZStack([
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: VxBox(
                          child: red.category.text.semiBold.white.make().px16(),
                        ).height(50).alignCenter.make(),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: VStack(
                          [
                            red.name.text.xl.white.bold.make(),
                            red.tagline.text.sm.white.semiBold.make(),
                            10.heightBox
                          ],
                          crossAlignment: CrossAxisAlignment.center,
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: [
                            Icon(
                                _isPlaying
                                    ? CupertinoIcons.stop_circle
                                    : CupertinoIcons.play_circle,
                                color: Colors.white,
                                size: 50),
                          ].vStack())
                    ]))
                        .clip(Clip.antiAlias)
                        .bgImage(
                          DecorationImage(
                              image: NetworkImage(red.image),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken)),
                        )
                        .withRounded(value: 20.0)
                        .make()
                        .onInkDoubleTap(() {
                      _playMusic(red.url);
                    }).p16();
                  },
                ).centered()
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if (_isPlaying)
                "Playing Now - ${_selectedRadio.name} FM"
                    .text
                    .white
                    .semiBold
                    .makeCentered(),
              Icon(
                _isPlaying
                    ? CupertinoIcons.stop_circle
                    : CupertinoIcons.play_circle,
                color: Colors.white,
                size: 50.0,
              ).onInkDoubleTap(() {
                if (_isPlaying) {
                  _audioPlayer.stop();
                } else {
                  _playMusic(_selectedRadio.url);
                }
              })
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12)
        ],
        fit: StackFit.expand,
      ),
    );
  }
}
