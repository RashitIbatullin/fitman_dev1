import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fitman_app/screens/client/full_screen_photo_editor.dart';
import 'package:fitman_app/widgets/dashed_crosshair_painter.dart';
import 'package:fitman_app/widgets/image_comparison_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/auth_provider.dart';

class PhotoComparisonScreen extends ConsumerStatefulWidget {
  final int? clientId;
  final String? initialStartPhotoUrl;
  final String? initialFinishPhotoUrl;
  final DateTime? initialStartPhotoDateTime;
  final DateTime? initialFinishPhotoDateTime;
  final String? initialStartProfilePhotoUrl;
  final String? initialFinishProfilePhotoUrl;
  final DateTime? initialStartProfilePhotoDateTime;
  final DateTime? initialFinishProfilePhotoDateTime;

  const PhotoComparisonScreen({
    super.key,
    this.clientId,
    this.initialStartPhotoUrl,
    this.initialFinishPhotoUrl,
    this.initialStartPhotoDateTime,
    this.initialFinishPhotoDateTime,
    this.initialStartProfilePhotoUrl,
    this.initialFinishProfilePhotoUrl,
    this.initialStartProfilePhotoDateTime,
    this.initialFinishProfilePhotoDateTime,
  });

  @override
  ConsumerState<PhotoComparisonScreen> createState() =>
      _PhotoComparisonScreenState();
}

class _PhotoComparisonScreenState extends ConsumerState<PhotoComparisonScreen> {
  late String? _startPhotoUrl;
  late String? _finishPhotoUrl;
  late DateTime? _startPhotoDateTime;
  late DateTime? _finishPhotoDateTime;

  late String? _startProfilePhotoUrl;
  late String? _finishProfilePhotoUrl;
  late DateTime? _startProfilePhotoDateTime;
  late DateTime? _finishProfilePhotoDateTime;

  final GlobalKey<_PhotoViewState> _startPhotoViewKey = GlobalKey();
  final GlobalKey<_PhotoViewState> _finishPhotoViewKey = GlobalKey();
  final GlobalKey<_PhotoViewState> _startProfilePhotoViewKey = GlobalKey();
  final GlobalKey<_PhotoViewState> _finishProfilePhotoViewKey = GlobalKey();

  bool _startFrontHasChanges = false;
  bool _finishFrontHasChanges = false;
  bool _startProfileHasChanges = false;
  bool _finishProfileHasChanges = false;

  @override
  void initState() {
    super.initState();
    _startPhotoUrl = widget.initialStartPhotoUrl;
    _finishPhotoUrl = widget.initialFinishPhotoUrl;
    _startPhotoDateTime = widget.initialStartPhotoDateTime;
    _finishPhotoDateTime = widget.initialFinishPhotoDateTime;

    _startProfilePhotoUrl = widget.initialStartProfilePhotoUrl;
    _finishProfilePhotoUrl = widget.initialFinishProfilePhotoUrl;
    _startProfilePhotoDateTime = widget.initialStartProfilePhotoDateTime;
    _finishProfilePhotoDateTime = widget.initialFinishProfilePhotoDateTime;
  }

  void _onPhotoSaved(String type, String newUrl, DateTime newDateTime) {
    setState(() {
      if (type == 'start_front') {
        _startPhotoUrl = newUrl;
        _startPhotoDateTime = newDateTime;
        _startFrontHasChanges = false;
      } else if (type == 'finish_front') {
        _finishPhotoUrl = newUrl;
        _finishPhotoDateTime = newDateTime;
        _finishFrontHasChanges = false;
      } else if (type == 'start_profile') {
        _startProfilePhotoUrl = newUrl;
        _startProfilePhotoDateTime = newDateTime;
        _startProfileHasChanges = false;
      } else if (type == 'finish_profile') {
        _finishProfilePhotoUrl = newUrl;
        _finishProfilePhotoDateTime = newDateTime;
        _finishProfileHasChanges = false;
      }
    });
  }

  Future<void> _pickAndUploadImage(String photoType) async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null) {
        final platformFile = result.files.single;
        final fileName = platformFile.name;
        Uint8List? fileBytes = platformFile.bytes ??
            (platformFile.path != null
                ? await File(platformFile.path!).readAsBytes()
                : null);

        if (fileBytes != null) {
          try {
            final Map<String, dynamic> responseData;
            if (widget.clientId != null) {
              responseData =
                  await ApiService.uploadAnthropometryPhotoForClient(
                clientId: widget.clientId!,
                photoBytes: fileBytes,
                fileName: fileName,
                type: photoType,
                photoDateTime: null,
              );
            } else {
              responseData = await ApiService.uploadAnthropometryPhoto(
                photoBytes: fileBytes,
                fileName: fileName,
                type: photoType,
                photoDateTime: null,
              );
            }
            final newUrl = responseData['url'];
            final newDateTime = responseData['photo_date_time'] != null
                ? DateTime.parse(responseData['photo_date_time'])
                : DateTime.now();
            _onPhotoSaved(photoType, newUrl, newDateTime);
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка загрузки фото: $e')),
            );
          } // <-- Fixed: Added missing closing brace
        }
      }
    } catch (e) {
      if (!mounted) return; // <-- Fixed: Added mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе файла: $e')),
      );
    }
  }

  Widget _buildPhotoSection(
    String? photoUrl,
    DateTime? photoDateTime,
    String title,
    String type,
    bool canUploadPhoto,
    GlobalKey<_PhotoViewState> key,
    bool hasChanges,
  ) {
    final formattedDate = photoDateTime != null
        ? '${photoDateTime.day.toString().padLeft(2, '0')}.${photoDateTime.month.toString().padLeft(2, '00')}.${photoDateTime.year} ${photoDateTime.hour.toString().padLeft(2, '0')}:${photoDateTime.minute.toString().padLeft(2, '0')}'
        : 'Нет даты';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            if (key.currentState?._imageUrlWithCacheBust == null) return;

            final result = await Navigator.push<dynamic>(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenPhotoEditor(
                  imageUrl: key.currentState!._imageUrlWithCacheBust!,
                  initialTransform: key.currentState!._currentTransform,
                  showCrosshair: true,
                ),
              ),
            );

            if (result != null && result is (ui.Image, Matrix4)) {
              // Set the flag in the parent to enable the save button
              setState(() {
                switch (type) {
                  case 'start_front':
                    _startFrontHasChanges = true;
                    break;
                  case 'finish_front':
                    _finishFrontHasChanges = true;
                    break;
                  case 'start_profile':
                    _startProfileHasChanges = true;
                    break;
                  case 'finish_profile':
                    _finishProfileHasChanges = true;
                    break;
                }
              });
              // Pass the image down to the child to render
              key.currentState?.updateState(
                newImage: result.$1,
                newTransform: result.$2,
              );
            }
          },
          child: _PhotoView(
            key: key,
            photoUrl: photoUrl,
            type: type,
            clientId: widget.clientId,
            onPhotoSaved: _onPhotoSaved,
          ),
        ),
        const SizedBox(height: 8),
        Text(formattedDate),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (canUploadPhoto)
              IconButton(
                icon: const Icon(Icons.cloud_upload),
                tooltip: 'Загрузить фото',
                onPressed: () => _pickAndUploadImage(type),
              ),
            const SizedBox(width: 8),
            if (canUploadPhoto)
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Сохранить изменения',
                onPressed: hasChanges ? () => key.currentState?.save() : null,
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _navigateToComparisonScreen({
    required String? startUrl,
    required String? finishUrl,
    required GlobalKey<_PhotoViewState> startKey,
    required GlobalKey<_PhotoViewState> finishKey,
    required String title,
  }) async {
    // This function now retrieves the rendered image data before navigating.
    final startState = startKey.currentState;
    final finishState = finishKey.currentState;

    if (startState == null || finishState == null) return;

    Uint8List? startBytes;
    if (startState._renderedImage != null) {
      final byteData = await startState._renderedImage!
          .toByteData(format: ui.ImageByteFormat.png);
      startBytes = byteData?.buffer.asUint8List();
    }

    Uint8List? finishBytes;
    if (finishState._renderedImage != null) {
      final byteData = await finishState._renderedImage!
          .toByteData(format: ui.ImageByteFormat.png);
      finishBytes = byteData?.buffer.asUint8List();
    }

    if (startUrl != null && finishUrl != null) {
      if (!mounted) return; // FIX: Add mounted check before using context
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: ImageComparisonSlider(
            before: startBytes != null
                ? Image.memory(startBytes, fit: BoxFit.contain)
                : Image.network(
                    Uri.parse(ApiService.baseUrl)
                        .replace(path: startUrl)
                        .toString(),
                    fit: BoxFit.contain,
                  ),
            after: finishBytes != null
                ? Image.memory(finishBytes, fit: BoxFit.contain)
                : Image.network(
                    Uri.parse(ApiService.baseUrl)
                        .replace(path: finishUrl)
                        .toString(),
                    fit: BoxFit.contain,
                  ),
          ),
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.value?.user;
    final canUploadPhoto = user != null &&
        (!user.roles.any((role) => role.name == 'client') ||
            user.roles.length > 1);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, {
          'startPhotoUrl': _startPhotoUrl,
          'finishPhotoUrl': _finishPhotoUrl,
          'startPhotoDateTime': _startPhotoDateTime,
          'finishPhotoDateTime': _finishPhotoDateTime,
          'startProfilePhotoUrl': _startProfilePhotoUrl,
          'finishProfilePhotoUrl': _finishProfilePhotoUrl,
          'startProfilePhotoDateTime': _startProfilePhotoDateTime,
          'finishProfilePhotoDateTime': _finishProfilePhotoDateTime,
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Сравнение по фото'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_startPhotoUrl != null && _finishPhotoUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () => _navigateToComparisonScreen(
                      startUrl: _startPhotoUrl,
                      finishUrl: _finishPhotoUrl,
                      startKey: _startPhotoViewKey,
                      finishKey: _finishPhotoViewKey,
                      title: 'Сравнение анфас',
                    ),
                    child: const Text('Сравнить анфас'),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Загрузите обе фотографии ("Анфас начало" и "Анфас окончание"), чтобы увидеть сравнение.',
                    textAlign: TextAlign.center,
                  ),
                ),
              const Divider(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPhotoSection(
                        _startPhotoUrl,
                        _startPhotoDateTime,
                        'Анфас начало',
                        'start_front',
                        canUploadPhoto,
                        _startPhotoViewKey,
                        _startFrontHasChanges),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPhotoSection(
                        _finishPhotoUrl,
                        _finishPhotoDateTime,
                        'Анфас окончание',
                        'finish_front',
                        canUploadPhoto,
                        _finishPhotoViewKey,
                        _finishFrontHasChanges),
                  ),
                ],
              ),
              const Divider(height: 32),
              if (_startProfilePhotoUrl != null &&
                  _finishProfilePhotoUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () => _navigateToComparisonScreen(
                      startUrl: _startProfilePhotoUrl,
                      finishUrl: _finishProfilePhotoUrl,
                      startKey: _startProfilePhotoViewKey,
                      finishKey: _finishProfilePhotoViewKey,
                      title: 'Сравнение профиль',
                    ),
                    child: const Text('Сравнить профиль'),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Загрузите обе фотографии ("Профиль начало" и "Профиль окончание"), чтобы увидеть сравнение.',
                    textAlign: TextAlign.center,
                  ),
                ),
              const Divider(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPhotoSection(
                        _startProfilePhotoUrl,
                        _startProfilePhotoDateTime,
                        'Профиль начало',
                        'start_profile',
                        canUploadPhoto,
                        _startProfilePhotoViewKey,
                        _startProfileHasChanges),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPhotoSection(
                        _finishProfilePhotoUrl,
                        _finishProfilePhotoDateTime,
                        'Профиль окончание',
                        'finish_profile',
                        canUploadPhoto,
                        _finishProfilePhotoViewKey,
                        _finishProfileHasChanges),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoView extends StatefulWidget {
  final String? photoUrl;
  final String type;
  final int? clientId;
  final void Function(String type, String newUrl, DateTime newDateTime)
      onPhotoSaved;

  const _PhotoView({
    super.key,
    this.photoUrl,
    required this.type,
    this.clientId,
    required this.onPhotoSaved,
  });

  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<_PhotoView> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  String? _imageUrlWithCacheBust;
  ui.Image? _renderedImage;
  Matrix4 _currentTransform = Matrix4.identity();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _updateImageUrl();
  }

  @override
  void didUpdateWidget(covariant _PhotoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photoUrl != oldWidget.photoUrl) {
      _updateImageUrl();
      setState(() {
        _renderedImage = null;
        _currentTransform = Matrix4.identity();
      });
    }
  }

  void _updateImageUrl() {
    if (widget.photoUrl != null) {
      setState(() {
        _imageUrlWithCacheBust =
            '${Uri.parse(ApiService.baseUrl).replace(path: widget.photoUrl!).toString()}?v=${widget.photoUrl.hashCode}';
      });
    } else {
      setState(() {
        _imageUrlWithCacheBust = null;
      });
    }
  }

  void updateState({required ui.Image newImage, required Matrix4 newTransform}) {
    setState(() {
      _renderedImage = newImage;
      _currentTransform = newTransform;
    });
  }

  Future<void> save() async {
    final completer = Completer<void>();
    setState(() {
      _isSaving = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      completer.complete();
    });

    try {
      // Wait for the frame to be rendered without the crosshair
      await completer.future;

      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(
          pixelRatio: 1.5); // Use a moderate pixelRatio
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) {
        throw Exception('Could not generate image bytes.');
      }

      final String fileName =
          'photo_${DateTime.now().millisecondsSinceEpoch}.png';

      final Map<String, dynamic> responseData;
      if (widget.clientId != null) {
        responseData = await ApiService.uploadAnthropometryPhotoForClient(
          clientId: widget.clientId!,
          photoBytes: pngBytes,
          fileName: fileName,
          type: widget.type,
          photoDateTime: DateTime.now(),
        );
      } else {
        responseData = await ApiService.uploadAnthropometryPhoto(
          photoBytes: pngBytes,
          fileName: fileName,
          type: widget.type,
          photoDateTime: DateTime.now(),
        );
      }

      final newUrl = responseData['url'];
      final newDateTime = responseData['photo_date_time'] != null
          ? DateTime.parse(responseData['photo_date_time'])
          : DateTime.now();

      widget.onPhotoSaved(widget.type, newUrl, newDateTime);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Фотография успешно сохранена'),
            backgroundColor: Colors.green,
          ),
        );
      }
      setState(() {
        _renderedImage = null;
        _currentTransform = Matrix4.identity();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения фото: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            RepaintBoundary(
              key: _repaintBoundaryKey,
              child: _renderedImage != null
                  ? RawImage(image: _renderedImage!, fit: BoxFit.contain)
                  : (_imageUrlWithCacheBust != null
                      ? Image.network(
                          _imageUrlWithCacheBust!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.error, size: 50)),
                        )
                      : const Center(child: Text('Фото не загружено'))),
            ),
            if (!_isSaving)
              IgnorePointer(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: DashedCrosshairPainter(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}