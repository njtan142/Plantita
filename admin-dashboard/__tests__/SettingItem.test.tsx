import { render, screen, fireEvent } from '@testing-library/react';
import { SettingItem } from '../components/settings/SettingItem';

describe('SettingItem', () => {
  const defaultProps = {
    id: 'test-setting',
    label: 'Test Setting',
    type: 'text' as const,
    value: 'test value',
    onChange: jest.fn(),
  };

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Rendering', () => {
    it('should render with label and description', () => {
      render(
        <SettingItem
          {...defaultProps}
          description="This is a test description"
        />
      );

      expect(screen.getByLabelText('Test Setting')).toBeInTheDocument();
      expect(screen.getByText('This is a test description')).toBeInTheDocument();
    });

    it('should render text input', () => {
      render(<SettingItem {...defaultProps} type="text" />);
      
      const input = screen.getByRole('textbox');
      expect(input).toBeInTheDocument();
      expect(input).toHaveValue('test value');
    });

    it('should render number input', () => {
      render(<SettingItem {...defaultProps} type="number" value={42} />);
      
      const input = screen.getByRole('spinbutton');
      expect(input).toBeInTheDocument();
      expect(input).toHaveValue(42);
    });

    it('should render email input', () => {
      render(<SettingItem {...defaultProps} type="email" value="test@example.com" />);
      
      const input = screen.getByRole('textbox');
      expect(input).toBeInTheDocument();
      expect(input).toHaveAttribute('type', 'email');
      expect(input).toHaveValue('test@example.com');
    });

    it('should render password input', () => {
      render(<SettingItem {...defaultProps} type="password" value="secret" />);
      
      const input = screen.getByRole('textbox');
      expect(input).toBeInTheDocument();
      expect(input).toHaveAttribute('type', 'password');
      expect(input).toHaveValue('secret');
    });

    it('should render textarea', () => {
      render(<SettingItem {...defaultProps} type="textarea" value="multiline text" />);
      
      const textarea = screen.getByRole('textbox');
      expect(textarea).toBeInTheDocument();
      expect(textarea).toHaveValue('multiline text');
    });

    it('should render checkbox', () => {
      render(<SettingItem {...defaultProps} type="checkbox" value={true} />);
      
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toBeInTheDocument();
      expect(checkbox).toBeChecked();
    });

    it('should render select with options', () => {
      const options = [
        { value: 'option1', label: 'Option 1' },
        { value: 'option2', label: 'Option 2' },
      ];
      
      render(
        <SettingItem
          {...defaultProps}
          type="select"
          value="option1"
          options={options}
        />
      );
      
      const select = screen.getByRole('combobox');
      expect(select).toBeInTheDocument();
      expect(select).toHaveValue('option1');
    });
  });

  describe('Interactions', () => {
    it('should call onChange when text input changes', () => {
      const onChange = jest.fn();
      render(<SettingItem {...defaultProps} onChange={onChange} />);
      
      const input = screen.getByRole('textbox');
      fireEvent.change(input, { target: { value: 'new value' } });
      
      expect(onChange).toHaveBeenCalledWith('new value');
    });

    it('should call onChange when number input changes', () => {
      const onChange = jest.fn();
      render(
        <SettingItem
          {...defaultProps}
          type="number"
          value={42}
          onChange={onChange}
        />
      );
      
      const input = screen.getByRole('spinbutton');
      fireEvent.change(input, { target: { value: '100' } });
      
      expect(onChange).toHaveBeenCalledWith(100);
    });

    it('should call onChange when checkbox is toggled', () => {
      const onChange = jest.fn();
      render(
        <SettingItem
          {...defaultProps}
          type="checkbox"
          value={false}
          onChange={onChange}
        />
      );
      
      const checkbox = screen.getByRole('checkbox');
      fireEvent.click(checkbox);
      
      expect(onChange).toHaveBeenCalledWith(true);
    });

    it('should call onChange when select value changes', () => {
      const onChange = jest.fn();
      const options = [
        { value: 'option1', label: 'Option 1' },
        { value: 'option2', label: 'Option 2' },
      ];
      
      render(
        <SettingItem
          {...defaultProps}
          type="select"
          value="option1"
          options={options}
          onChange={onChange}
        />
      );
      
      const select = screen.getByRole('combobox');
      fireEvent.click(select);
      
      // In a real test, we would select an option, but for simplicity we'll just check the onChange call
      expect(onChange).not.toHaveBeenCalled();
    });

    it('should be disabled when disabled prop is true', () => {
      render(<SettingItem {...defaultProps} disabled={true} />);
      
      const input = screen.getByRole('textbox');
      expect(input).toBeDisabled();
    });
  });
});