import { cn } from '../lib/utils';

describe('utils', () => {
  describe('cn', () => {
    it('should merge basic classes', () => {
      expect(cn('class1', 'class2')).toBe('class1 class2');
    });

    it('should handle conditional classes', () => {
      expect(cn('class1', { class2: true, class3: false })).toBe('class1 class2');
    });

    it('should handle arrays of classes', () => {
      expect(cn(['class1', 'class2'])).toBe('class1 class2');
    });

    it('should resolve tailwind class conflicts correctly', () => {
      expect(cn('p-4', 'p-2')).toBe('p-2');
      expect(cn('bg-red-500', 'bg-blue-500')).toBe('bg-blue-500');
    });

    it('should handle undefined and null values', () => {
      expect(cn('class1', undefined, null, 'class2')).toBe('class1 class2');
    });

    it('should handle a mix of inputs', () => {
      expect(
        cn(
          'text-sm font-medium',
          { 'text-red-500': true },
          ['p-4', 'mt-2'],
          'text-lg'
        )
      ).toBe('font-medium text-red-500 p-4 mt-2 text-lg');
    });
  });
});
