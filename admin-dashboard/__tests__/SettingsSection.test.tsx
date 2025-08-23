import { render, screen } from '@testing-library/react';
import { SettingsSection } from '../components/settings/SettingsSection';

describe('SettingsSection', () => {
  it('should render title and children', () => {
    render(
      <SettingsSection title="Test Section">
        <div>Test Content</div>
      </SettingsSection>
    );

    expect(screen.getByText('Test Section')).toBeInTheDocument();
    expect(screen.getByText('Test Content')).toBeInTheDocument();
  });

  it('should render description when provided', () => {
    render(
      <SettingsSection 
        title="Test Section" 
        description="Test description"
      >
        <div>Test Content</div>
      </SettingsSection>
    );

    expect(screen.getByText('Test Section')).toBeInTheDocument();
    expect(screen.getByText('Test description')).toBeInTheDocument();
    expect(screen.getByText('Test Content')).toBeInTheDocument();
  });

  it('should render without description when not provided', () => {
    render(
      <SettingsSection title="Test Section">
        <div>Test Content</div>
      </SettingsSection>
    );

    expect(screen.getByText('Test Section')).toBeInTheDocument();
    expect(screen.getByText('Test Content')).toBeInTheDocument();
    expect(screen.queryByText('Test description')).not.toBeInTheDocument();
  });
});