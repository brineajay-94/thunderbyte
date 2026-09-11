import React from 'react';
import { Field as FormikField, FieldProps } from 'formik';
import styled from 'styled-components/macro';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { IconDefinition } from '@fortawesome/fontawesome-svg-core';

interface Props {
    name: string;
    label: string;
    type?: string;
    icon?: IconDefinition;
    placeholder?: string;
    autoComplete?: string;
    disabled?: boolean;
}

const Label = styled.label`
    display: block;
    font-size: 0.85rem;
    font-weight: 600;
    color: rgba(255, 255, 255, 0.7);
    margin-bottom: 8px;
`;

const Icon = styled.span`
    position: absolute;
    left: 14px;
    top: 50%;
    transform: translateY(-50%);
    color: rgba(255, 255, 255, 0.45);
    font-size: 0.9rem;
    transition: color 0.2s;
    pointer-events: none;
`;

const Wrapper = styled.div`
    position: relative;

    &:focus-within ${Icon} {
        color: #3b82f6;
    }
`;

const StyledInput = styled.input<{ hasError?: boolean }>`
    width: 100%;
    padding: 12px 14px 12px 40px;
    background: rgba(255, 255, 255, 0.06);
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: 8px;
    font-size: 0.95rem;
    font-family: 'Inter', sans-serif;
    color: #ffffff;
    transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
    outline: none;

    &::placeholder {
        color: rgba(255, 255, 255, 0.35);
    }

    &:focus {
        border-color: #3b82f6;
        background: rgba(255, 255, 255, 0.09);
        box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
    }

    &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
    }

    ${(props) => props.hasError && `border-color: rgba(239, 68, 68, 0.6);`};
`;

const ErrorMessage = styled.p`
    margin-top: 6px;
    font-size: 0.8rem;
    color: #fca5a5;
`;

const LoginInput = React.forwardRef<HTMLInputElement, Props>(
    ({ name, label, type = 'text', icon, placeholder, autoComplete, disabled }, ref) => (
        <FormikField name={name}>
            {({ field, form: { errors, touched } }: FieldProps) => (
                <div>
                    <Label htmlFor={name}>{label}</Label>
                    <Wrapper>
                        {icon && (
                            <Icon>
                                <FontAwesomeIcon icon={icon} />
                            </Icon>
                        )}
                        <StyledInput
                            id={name}
                            ref={ref}
                            {...field}
                            type={type}
                            placeholder={placeholder}
                            autoComplete={autoComplete}
                            disabled={disabled}
                            hasError={!!(touched[field.name] && errors[field.name])}
                        />
                    </Wrapper>
                    {touched[field.name] && errors[field.name] ? (
                        <ErrorMessage>
                            {(errors[field.name] as string).charAt(0).toUpperCase() +
                                (errors[field.name] as string).slice(1)}
                        </ErrorMessage>
                    ) : null}
                </div>
            )}
        </FormikField>
    )
);
LoginInput.displayName = 'LoginInput';

export default LoginInput;