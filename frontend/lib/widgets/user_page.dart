import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/friends_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/widgets/profile.dart';

class UserPage extends StatefulWidget {
  final String token;
  const UserPage({Key? key, required this.token}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _userService = UserService();
  final FriendsService _friendsService = FriendsService();

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  bool _isLoading = true;
  String? _loadError;

  List<UserProfile> _allUsers = [];
  List<UserProfile> _filtered = [];

  // do'stlik so'rovi yuborilgan/yuborilmagan holatini kesh qilib boramiz
  final Map<String, bool> _sentCache = {}; // username -> sent?
  final Set<String> _sending = {}; // hozirda yuborilayotganlar

  @override
  void initState() {
    super.initState();
    _loadNonFriends();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadNonFriends() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final list = await _userService.fetchNonFriends(widget.token);

      for (final u in list) {
        final name = u.userName ?? '';
        if (name.isNotEmpty) {
          try {
            final sent = await _friendsService.isFriendsRequestSent(name, widget.token);
            _sentCache[name] = sent;
          } catch (_) {
          }
        }
      }

      _allUsers = list;
      _applyFilter();
    } catch (e) {
      _loadError = "Foydalanuvchilarni yuklashda xatolik: $e";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      _filtered = List<UserProfile>.from(_allUsers);
    } else {
      _filtered = _allUsers.where((u) {
        final name = (u.userName ?? '').toLowerCase();
        final fullName = (u.userName ?? '').toLowerCase();
        return name.contains(q) || fullName.contains(q);
      }).toList();
    }
    setState(() {});
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _applyFilter);
  }

  Future<void> _sendFriendRequest(String username) async {
    if (username.isEmpty || _sending.contains(username)) return;
    setState(() {
      _sending.add(username);
    });
    try {
      await _friendsService.sendFriendsRequest(
        username,
        widget.token,
        _loadNonFriends,
        context,
      );
      // optimistik yangilash
      _sentCache[username] = true;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Do'stlik so'rovi yuborildi")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Do'stlik so'rovi yuborishda xato: $e")),
      );
    } finally {
      setState(() {
        _sending.remove(username);
      });
    }
  }

  Future<void> _refresh() async {
    await _loadNonFriends();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Yangi do'stlar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNonFriends,
            tooltip: "Yangilash",
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.h),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: _SearchField(controller: _searchCtrl),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isLoading
              ? const _LoadingState()
              : (_loadError != null)
              ? _ErrorState(message: _loadError!, onRetry: _loadNonFriends)
              : (_filtered.isEmpty)
              ? const _EmptyState()
              : ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 0.4,
              color: theme.dividerColor.withOpacity(0.5),
            ),
            itemBuilder: (context, index) {
              final user = _filtered[index];
              final username = user.userName ?? "Noma'lum";
              final isSent = _sentCache[username] ?? false;
              final sendingNow = _sending.contains(username);

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(userProfile: user),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _Avatar(imageUrl: user.profileImage),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.userName?.trim().isNotEmpty == true
                                  ? user.userName!
                                  : (user.userName ?? "Noma'lum"),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 16.sp, color: theme.hintColor),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    "@$username",
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _AddFriendButton(
                        isSent: isSent,
                        loading: sendingNow,
                        onTap: () => _sendFriendRequest(username),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: "Qidirish...",
        prefixIcon: const Icon(Icons.search),
        contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  const _Avatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final size = 48.r;
    final provider = (imageUrl != null && imageUrl!.trim().isNotEmpty)
        ? NetworkImage(ApiService().formatImageUrl(imageUrl!))
        : const AssetImage('assets/images/nouser.png');

    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: Image(
        image: provider as ImageProvider,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _AddFriendButton extends StatelessWidget {
  final bool isSent;
  final bool loading;
  final VoidCallback onTap;

  const _AddFriendButton({
    required this.isSent,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isSent) {
      return OutlinedButton.icon(
        onPressed: null, // disabled
        icon: const Icon(Icons.check_circle_outline),
        label: const Text("Yuborilgan"),
      );
    }
    return ElevatedButton.icon(
      onPressed: loading ? null : onTap,
      icon: loading
          ? const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : const Icon(Icons.person_add_alt_1),
      label: const Text("Add friend"),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sentiment_satisfied_alt, size: 56, color: theme.hintColor),
            const SizedBox(height: 12),
            Text(
              "Boshqa foydalanuvchi topilmadi",
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "Keyinroq urinib ko‘ring yoki qidiruvdan foydalaning.",
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text("Xatolik", style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Qayta urinish"),
            ),
          ],
        ),
      ),
    );
  }
}
