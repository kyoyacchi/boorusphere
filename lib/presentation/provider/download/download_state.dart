import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/download/entity/downloads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_state.g.dart';

@riverpod
class DownloadState extends _$DownloadState {
  @override
  Downloads build() {
    Future(_populate);
    return const Downloads();
  }

  Future<void> _populate() async {
    final repo = ref.read(downloadRepoProvider);
    state = Downloads(
      entries: repo.getEntries(),
      progresses: await repo.getProgress(),
    );
  }

  Future<void> add(DownloadEntry entry) async {
    final repo = ref.read(downloadRepoProvider);
    await repo.add(entry);
    state = state.copyWith(
      entries: [
        ...state.entries.where((it) => it.id != entry.id),
        entry,
      ],
    );
  }

  Future<void> remove(String id) async {
    final repo = ref.read(downloadRepoProvider);
    await repo.remove(id);
    state = state.copyWith(
      entries: [
        ...state.entries.where((it) => it.id != id),
      ],
      progresses: {
        ...state.progresses.where((it) => it.id != id),
      },
    );
  }

  Future<void> update(String id, DownloadEntry entry) async {
    final repo = ref.read(downloadRepoProvider);
    await repo.remove(id);
    await repo.add(entry);
    state = state.copyWith(
      entries: [
        ...state.entries.where((it) => it.id != entry.id),
        entry,
      ],
      progresses: {
        ...state.progresses.where((it) => it.id != id && it.id != entry.id),
      },
    );
  }

  updateProgress(DownloadProgress progress) {
    state = state.copyWith(
      progresses: {
        ...state.progresses.where((it) => it.id != progress.id),
        progress,
      },
    );
  }

  Future<void> clear() async {
    final repo = ref.read(downloadRepoProvider);
    await repo.clear();
    state = const Downloads();
  }
}
