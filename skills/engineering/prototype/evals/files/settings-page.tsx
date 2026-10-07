// Existing /settings route of the account app. Data fetching and auth stay above this component.
import { useSettings } from '../hooks/useSettings';

export default function SettingsPage() {
  const settings = useSettings();
  return (
    <main>
      <h1>Settings</h1>
      <section>
        <h2>Profile</h2>
        <p>{settings.displayName}</p>
      </section>
      <section>
        <h2>Notifications</h2>
        <p>{settings.emailDigest ? 'Daily digest on' : 'Daily digest off'}</p>
      </section>
    </main>
  );
}
