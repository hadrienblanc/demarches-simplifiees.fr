import {
  enable,
  disable,
  hasClass,
  addClass,
  removeClass,
  ResponseError
} from '@utils';
import { z } from 'zod';

import { ApplicationController } from './application_controller';

const Gon = z.object({
  autosave: z.object({ status_visible_duration: z.number() })
});

declare const window: Window & typeof globalThis & { gon: unknown };
const { status_visible_duration } = Gon.parse(window.gon).autosave;

const AUTOSAVE_STATUS_VISIBLE_DURATION = status_visible_duration;

// This is a controller we attach to the status area in the main form. It
// coordinates notifications and will dispatch `autosave:retry` event if user
// decides to retry after an error.
//
export class AutosaveStatusController extends ApplicationController {
  static targets = ['retryButton'];

  declare readonly retryButtonTarget: HTMLButtonElement;

  connect(): void {
    this.onGlobal('autosave:enqueue', () => this.didEnqueue());
    this.onGlobal('autosave:end', () => this.didSucceed());
    this.onGlobal<CustomEvent>('autosave:error', (event) =>
      this.didFail(event)
    );
  }

  onClickRetryButton() {
    this.globalDispatch('autosave:retry');
  }

  private didEnqueue() {
    disable(this.retryButtonTarget);
  }

  private didSucceed() {
    enable(this.retryButtonTarget);
    this.setState('succeeded');
    this.debounce(this.hideSucceededStatus, AUTOSAVE_STATUS_VISIBLE_DURATION);
  }

  private didFail(event: CustomEvent<{ error: ResponseError }>) {
    const error = event.detail.error;

    if (error.response?.status == 401) {
      // If we are unauthenticated, reload the page using a GET request.
      // This will allow Devise to properly redirect us to sign-in, and then back to this page.
      document.location.reload();
      return;
    }

    enable(this.retryButtonTarget);
    this.setState('failed');

    const shouldLogError = !error.response || error.response.status != 0; // ignore timeout errors
    if (shouldLogError) {
      this.logError(error);
    }
  }

  private setState(state: 'succeeded' | 'failed' | 'idle') {
    const autosave = this.element as HTMLDivElement;
    if (autosave) {
      // Re-apply the state even if already present, to get a nice animation
      removeClass(autosave, 'autosave-state-idle');
      removeClass(autosave, 'autosave-state-succeeded');
      removeClass(autosave, 'autosave-state-failed');
      autosave.offsetHeight; // flush animations
      addClass(autosave, `autosave-state-${state}`);
    }
  }

  private hideSucceededStatus() {
    if (hasClass(this.element as HTMLElement, 'autosave-state-succeeded')) {
      this.setState('idle');
    }
  }

  private logError(error: ResponseError) {
    if (error && error.message) {
      error.message = `[Autosave] ${error.message}`;
      console.error(error);
      this.globalDispatch('sentry:capture-exception', error);
    }
  }
}
