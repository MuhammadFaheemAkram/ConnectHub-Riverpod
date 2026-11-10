/// The app's automatic-retry policy for providers that fail: none.
///
/// By default Riverpod 3 retries a provider that throws: up to 10 times,
/// waiting 200 ms, then 400 ms, … up to 6.4 s. While it waits, the provider
/// reports `AsyncLoading`, not the error. Every load in ConnectHub is shown
/// to the user, with "Try again" on failure, so a default retry would keep a
/// spinner up for about 40 seconds against a server that already said no.
///
/// So the app's `ProviderScope` turns retry off, and the UI decides. A
/// provider that should retry by itself opts in with `@Riverpod(retry: …)`,
/// and says why next to it.
Duration? noAutomaticRetry(int retryCount, Object error) => null;
