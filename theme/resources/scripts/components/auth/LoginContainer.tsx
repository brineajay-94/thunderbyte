import React, { useEffect, useRef, useState } from 'react';
import { Link, RouteComponentProps } from 'react-router-dom';
import login from '@/api/auth/login';
import LoginFormContainer from '@/components/auth/LoginFormContainer';
import { useStoreState } from 'easy-peasy';
import { Formik, FormikHelpers } from 'formik';
import { object, string } from 'yup';
import LoginInput from '@/components/auth/LoginInput';
import tw from 'twin.macro';
import Button from '@/components/elements/Button';
import Reaptcha from 'reaptcha';
import useFlash from '@/plugins/useFlash';
import { faEnvelope, faKey } from '@fortawesome/free-solid-svg-icons';

interface Values {
    username: string;
    password: string;
}

const LoginContainer = ({ history }: RouteComponentProps) => {
    const ref = useRef<Reaptcha>(null);
    const [token, setToken] = useState('');

    const { clearFlashes, clearAndAddHttpError } = useFlash();
    const { enabled: recaptchaEnabled, siteKey } = useStoreState((state) => state.settings.data!.recaptcha);

    useEffect(() => {
        clearFlashes();
    }, []);

    const onSubmit = (values: Values, { setSubmitting }: FormikHelpers<Values>) => {
        clearFlashes();

        // If there is no token in the state yet, request the token and then abort this submit request
        // since it will be re-submitted when the recaptcha data is returned by the component.
        if (recaptchaEnabled && !token) {
            ref.current!.execute().catch((error) => {
                console.error(error);

                setSubmitting(false);
                clearAndAddHttpError({ error });
            });

            return;
        }

        login({ ...values, recaptchaData: token })
            .then((response) => {
                if (response.complete) {
                    // @ts-expect-error this is valid
                    window.location = response.intended || '/';
                    return;
                }

                history.replace('/auth/login/checkpoint', { token: response.confirmationToken });
            })
            .catch((error) => {
                console.error(error);

                setToken('');
                if (ref.current) ref.current.reset();

                setSubmitting(false);
                clearAndAddHttpError({ error });
            });
    };

    return (
        <Formik
            onSubmit={onSubmit}
            initialValues={{ username: '', password: '' }}
            validationSchema={object().shape({
                username: string().required('A username or email must be provided.'),
                password: string().required('Please enter your account password.'),
            })}
        >
            {({ isSubmitting, setSubmitting, submitForm }) => (
                <LoginFormContainer>
                    <LoginInput
                        name={'username'}
                        label={'Username or Email'}
                        type={'text'}
                        icon={faEnvelope}
                        placeholder={'Enter your username or email'}
                        autoComplete={'username'}
                        disabled={isSubmitting}
                    />
                    <div css={tw`mt-4`}>
                        <LoginInput
                            name={'password'}
                            label={'Password'}
                            type={'password'}
                            icon={faKey}
                            placeholder={'Enter your password'}
                            autoComplete={'current-password'}
                            disabled={isSubmitting}
                        />
                    </div>
                    <div css={tw`text-right mt-1 mb-5`}>
                        <Link
                            to={'/auth/password'}
                            css={tw`text-blue-500 font-semibold text-sm no-underline hover:text-blue-400 hover:underline`}
                        >
                            Forgot password?
                        </Link>
                    </div>
                    <Button
                        type={'submit'}
                        size={'xlarge'}
                        isLoading={isSubmitting}
                        disabled={isSubmitting}
                        css={tw`rounded-lg font-bold text-base tracking-wide shadow-[0_4px_15px_rgba(59,130,246,0.35)] hover:shadow-[0_8px_25px_rgba(59,130,246,0.5)]`}
                    >
                        Login
                    </Button>
                    {recaptchaEnabled && (
                        <Reaptcha
                            ref={ref}
                            size={'invisible'}
                            sitekey={siteKey || '_invalid_key'}
                            onVerify={(response) => {
                                setToken(response);
                                submitForm();
                            }}
                            onExpire={() => {
                                setSubmitting(false);
                                setToken('');
                            }}
                        />
                    )}
                </LoginFormContainer>
            )}
        </Formik>
    );
};

export default LoginContainer;